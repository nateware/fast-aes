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

#include "rijndael-alg-fst.h"

/* structure to store our key and keysize */
typedef struct {
    unsigned char key[256];  /* max key is 256 */
    int  key_bits;  /* 128, 192, 256  */

    /* Encryption Round Keys */
    u32 erk[4*(MAXNR + 1)];
    u32 initial_erk[4*(MAXNR + 1)];

    /* Decryption Round Keys */
    u32 drk[4*(MAXNR + 1)];
    u32 initial_drk[4*(MAXNR + 1)];

    /* Number of rounds. */
    int nr;
} fast_aes_t;

/* class functions */
void Init_fast_aes();
VALUE fast_aes_alloc(VALUE klass);
VALUE fast_aes_initialize(VALUE self, VALUE key);

/* get key value (not set) */
VALUE fast_aes_key(VALUE self);

/* setup round keys */
int fast_aes_initialize_state(fast_aes_t* fast_aes_config);
int fast_aes_initialize_state();

/* encryption routines */
VALUE fast_aes_encrypt(VALUE self, VALUE buffer);
VALUE fast_aes_decrypt(VALUE self, VALUE buffer);

/* garbage collection */
void fast_aes_mark(fast_aes_t* fast_aes_config);
void fast_aes_free(fast_aes_t* fast_aes_config);
void fast_aes_module_shutdown(fast_aes_t* fast_aes_config);    

#endif // __fast_aes_h

