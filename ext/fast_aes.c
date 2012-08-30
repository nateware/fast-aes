/*//////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// Part of the FastAES Ruby/C library implementation.
// Implementation in C originally by Christophe Devine.
//
////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////*/

#include <string.h>
#include <stdio.h>
#include <stdint.h>

#include "ruby.h"
#include "fast_aes.h"

/* Global boolean */
int fast_aes_do_gen_tables = 1;

/* Old school.  Oh yeah */
#ifndef RSTRING_PTR
  #define RSTRING_PTR(s) (RSTRING(s)->ptr)
  #define RSTRING_LEN(s) (RSTRING(s)->len)
#endif

/* Ruby buckets */
VALUE rb_cFastAES;

void Init_fast_aes()
{
    rb_cFastAES = rb_define_class("FastAES", rb_cObject);

    rb_define_alloc_func(rb_cFastAES, fast_aes_alloc);
    rb_define_method(rb_cFastAES, "initialize", fast_aes_initialize, 1);
    rb_define_method(rb_cFastAES, "encrypt", fast_aes_encrypt, 1);
    rb_define_method(rb_cFastAES, "decrypt", fast_aes_decrypt, 1);
    rb_define_method(rb_cFastAES, "key", fast_aes_key, 0);
}

VALUE fast_aes_key(VALUE self)
{
      /* get our "self" data structure (eg, member vars) */
    fast_aes_t* fast_aes;
      Data_Get_Struct(self, fast_aes_t, fast_aes);
    VALUE new_str = rb_str_new((const char*)fast_aes->key, fast_aes->key_bits/8);
    return new_str;
}

VALUE fast_aes_alloc(VALUE klass) 
{
    /* Initialize our structs */
    fast_aes_t *fast_aes = malloc(sizeof(fast_aes_t));

    /* Clear out memory */
    memset(fast_aes->key, 0, sizeof(fast_aes->key));
    memset(fast_aes->erk, 0, sizeof(fast_aes->erk));
    memset(fast_aes->drk, 0, sizeof(fast_aes->drk));
    memset(fast_aes->initial_erk, 0, sizeof(fast_aes->initial_erk));
    memset(fast_aes->initial_drk, 0, sizeof(fast_aes->initial_drk));

    return Data_Wrap_Struct(klass, fast_aes_mark, fast_aes_free, fast_aes);
}

VALUE fast_aes_initialize(VALUE self, VALUE key)
{
    /* get our "self" data structure (eg, member vars) */
    fast_aes_t* fast_aes;
      Data_Get_Struct(self, fast_aes_t, fast_aes);
        char error_mesg[350];

    int key_bits;
    char* key_data = StringValuePtr(key);

    /* determine key bits based on string length. breaks if try to use \0 in string. */
    key_bits = strlen(key_data)*8;
    switch(key_bits)
    {
        case 128:
        case 192:
        case 256:
            fast_aes->key_bits = key_bits;
            memcpy(fast_aes->key, key_data, key_bits/8);
            /*printf("AES key=%s, bits=%d\n", fast_aes->key, fast_aes->key_bits);*/
            break;
        default:
            sprintf(error_mesg, "AES key must be 128, 192, or 256 bits in length (got %d): %s", key_bits, key_data);
            rb_raise(rb_eArgError, error_mesg);
            return Qnil;
    }

    if (fast_aes_initialize_state(fast_aes)) {
        rb_raise(rb_eRuntimeError, "Failed to initialize AES internal state");
        return Qnil;    
    }
    return Qtrue;
}

int
fast_aes_initialize_state(fast_aes_t* fast_aes)
{
    fast_aes->nr = rijndaelKeySetupEnc(fast_aes->erk, fast_aes->key, fast_aes->key_bits);
    fast_aes->nr = rijndaelKeySetupDec(fast_aes->drk, fast_aes->key, fast_aes->key_bits);

    /* save values for fast re-initialization */
    memcpy(fast_aes->initial_erk, fast_aes->erk, sizeof(fast_aes->initial_erk));
    memcpy(fast_aes->initial_drk, fast_aes->drk, sizeof(fast_aes->initial_drk));
    return 0;
}

int 
fast_aes_reinitialize_state(fast_aes_t* fast_aes)
{
    /* put round keys for encryption and decryption back to their initial
     * states so we can encrypt and decrypt new items properly
     */
    memcpy(fast_aes->erk, fast_aes->initial_erk, sizeof(fast_aes->initial_erk));
    memcpy(fast_aes->drk, fast_aes->initial_drk, sizeof(fast_aes->initial_drk));
   
    return 0;
}

void fast_aes_module_shutdown( fast_aes_t* fast_aes )
{
}

/* This method **MUST** be present even if it does nothing */
void fast_aes_mark( fast_aes_t* fast_aes ) 
{
    /*rb_gc_mark(??);
    //should we mark each member here?  */
}

void fast_aes_free( fast_aes_t* fast_aes ) 
{
    fast_aes_module_shutdown(fast_aes);
    free(fast_aes);
}

VALUE fast_aes_encrypt(
    VALUE self,
    VALUE buffer
)
{
    /* get our "self" data structure (eg, member vars) */
    fast_aes_t* fast_aes;
    Data_Get_Struct(self, fast_aes_t, fast_aes);
 
    char* text = StringValuePtr(buffer);
    int bytes_in = RSTRING_LEN(buffer);
    char* data = malloc((bytes_in + 15) & -16);  /* auto-malloc min size in 16-byte increments */
    unsigned char temp[16];

    /* pointers to traverse text/data */
    unsigned char *ptext, *pdata;
    ptext = (unsigned char*)text;
    pdata = (unsigned char*)data;

    /*//////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //  This routine will encode all input bytes in entirety (AES always "succeeds")
    */
    int bytes_out = 0;

    /* set the state back to the start to allow for correct encryption
     * everytime we are passed data to encrypt
     */
    if (fast_aes_reinitialize_state(fast_aes)) {
        rb_raise(rb_eRuntimeError, "Failed to reinitialize AES internal state");
        return Qnil;    
    }

    /*//////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //  Perform block encodes 16 bytes at a time while we still have at least
    //  16 bytes of input remaining.
    */
    while (bytes_in >= 16) {
        rijndaelEncrypt(fast_aes->erk, fast_aes->nr, ptext, pdata);
        ptext += 16;
        pdata += 16;
        bytes_in  -= 16;
        bytes_out += 16;
    }

    /*//////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //  Have to catch any straggling bytes that are left after encoding the
    //  16-byte blocks. The policy here will be to pad the input with zeros.
    */
    if (bytes_in > 0) {
        memset(temp, 0, sizeof(temp));  /* pad with 0's */
        memcpy(temp, ptext, bytes_in);
        rijndaelEncrypt(fast_aes->erk, fast_aes->nr, temp, pdata);
        bytes_out += 16;
    }

    /* return the encrypted string */
    VALUE new_str = rb_str_new(pdata, bytes_out);
    free(data);
    return new_str;
}

VALUE fast_aes_decrypt(
    VALUE self,
    VALUE buffer
)
{
    /* get our "self" data structure (eg, member vars) */
    fast_aes_t* fast_aes;
    Data_Get_Struct(self, fast_aes_t, fast_aes);
 
    char* data = StringValuePtr(buffer);
    int bytes_in = RSTRING_LEN(buffer);
    char* text = malloc((bytes_in + 15) & -16);  /* auto-malloc min size in 16-byte increments */
    unsigned char temp[16];

    /* pointers to traverse text/data */
    unsigned char *ptext, *pdata;
    ptext = (unsigned char*)text;
    pdata = (unsigned char*)data;

    /*//////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //  This routine will encode all input bytes in entirety (AES always "succeeds")
    */
    int bytes_out = 0;

    /* set the state back to the start to allow for correct encryption
     * everytime we are passed data to encrypt
     */
    if (fast_aes_reinitialize_state(fast_aes)) {
        rb_raise(rb_eRuntimeError, "Failed to reinitialize AES internal state");
        return Qnil;    
    }

    /*//////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //  Perform block encodes 16 bytes at a time while we still have at least
    //  16 bytes of input remaining.
    */
    while (bytes_in >= 16) {
        rijndaelEncrypt(fast_aes->drk, fast_aes->nr, pdata, ptext);
        ptext += 16;
        pdata += 16;
        bytes_in  -= 16;
        bytes_out += 16;
    }

    /*//////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //  Have to catch any straggling bytes that are left after encoding the
    //  16-byte blocks. The policy here will be to pad the input with zeros.
    */
    if (bytes_in > 0) {
        memset(temp, 0, sizeof(temp));  /* pad with 0's */
        memcpy(temp, pdata, bytes_in);
        rijndaelEncrypt(fast_aes->drk, fast_aes->nr, temp, ptext);
        bytes_out += 16;
    }

    /*//////////////////////////////////////////////////////////////////////////
    // Strip trailing zeros, simple but effective.  This is something fucking
		// loose-cannon rjc couldn't figure out despite being a "genius".  He needs
		// a punch in the junk, I swear to god.
    */
    while (bytes_out > 0) {
        if (ptext[bytes_out - 1] != 0) break;
        bytes_out -= 1;
    }

    /* return the encrypted string */
    VALUE new_str = rb_str_new(ptext, bytes_out);
    free(text);
    return new_str;
}

