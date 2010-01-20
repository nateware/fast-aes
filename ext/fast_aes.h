/*//////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// Part of the FastAES Ruby/C library implementation.
//
// Original implementation: http://www.cycom.se/dl/sbd 
// File: sbd-1.27.tar.gz
//
// This Ruby extension, which is a derivitive work from Christophe Devine's original
// AEScrypt optimized C sources, provides an implementation of the United States
// Government's Advanced Encryption Standard (AES) (aka "Rijndael" algorithm).
// This is a 256-bit private-key block cipher written entirely in C for maximum
// portability across a perverse number of target architectures.
// 
// The Rijndael algorithm is 100% patent-free and completely unencumbered in any
// way, much unlike the RSA algorithms used in other software. We can use this
// cipher.
//
////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////*/
#ifndef __fast_aes_h
#define __fast_aes_h

/* structure to store our key and keysize */
typedef struct {
    char key[256];  /* max key is 256 */
    int  key_bits;  /* 128, 192, 256  */

    /* Encryption Round Keys */
    unsigned int erk[64];
	  unsigned int initial_erk[64];

    /* Decryption Round Keys */
    unsigned int drk[64];
	  unsigned int initial_drk[64];

    /* Number of rounds. */
    int nr;
} fast_aes_t;

/* functions */
void Init_fast_aes();
VALUE fast_aes_alloc(VALUE klass);
VALUE fast_aes_initialize(VALUE self, VALUE key);
void fast_aes_gen_tables();
int  fast_aes_initialize_state(fast_aes_t* fast_aes_config);
VALUE fast_aes_key(VALUE self);

/* garbage collection */
void fast_aes_mark(fast_aes_t* fast_aes_config);
void fast_aes_free(fast_aes_t* fast_aes_config);
void fast_aes_module_shutdown(fast_aes_t* fast_aes_config);    

/* and actual, bonafide encryption */
VALUE fast_aes_encrypt(VALUE self, VALUE buffer);

VALUE fast_aes_decrypt(VALUE self, VALUE buffer);

void fast_aes_encrypt_block(fast_aes_t* fast_aes, unsigned char input[16], unsigned char output[16]);
void fast_aes_decrypt_block(fast_aes_t* fast_aes, unsigned char input[16], unsigned char output[16]);

int fast_aes_reinitialize_state();
int fast_aes_initialize_state();

#endif // __fast_aes_h

