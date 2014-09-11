# FastAES - Simple but LOW security AES gem

**This gem is a relic from 5 years ago, when libraries such as OpenSSL did not work correctly with Ruby.**
**Use in new projects is strongly discouraged. The core Ruby OpenSSL library is faster and more secure.**

## Replacement Code

Refer to the [Ruby OpenSSL documentation](http://ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL.html)
for details on how to leverage AES:

    cipher = OpenSSL::Cipher.new 'AES-256-CBC'
    cipher.encrypt
    iv = cipher.random_iv

    pwd = 'some hopefully not too guessable password'
    salt = OpenSSL::Random.random_bytes 16
    iter = 20000
    key_len = cipher.key_len
    digest = OpenSSL::Digest::SHA256.new

    key = OpenSSL::PKCS5.pbkdf2_hmac(pwd, salt, iter, key_len, digest)
    cipher.key = key

    # Now encrypt the data:
    encrypted = cipher.update document
    encrypted << cipher.final

As mentioned, alot has changed in *5 years* since this gem was written.  Please do not use it anymore.

### Security Notice

A while back a [github issue](https://github.com/nateware/fast-aes/issues/2) was filed highlighting
that this gem supports ECB and not the (significantly) more secure CBC method.  You can read more details
on [Wikipedia's ECB writeup](http://en.wikipedia.org/wiki/Block_cipher_modes_of_operation#Electronic_codebook_.28ECB.29).

From the article:

> The disadvantage [of ECB] is that identical plaintext blocks are encrypted into
> identical ciphertext blocks; thus, it does not hide data patterns well. In some senses,
> it doesn't provide serious message confidentiality, and it is not recommended for use in
> cryptographic protocols at all.

If you're concerned about security, you need take responsibility for verifying whether this
gem meets your requirements.

## Original Into

This is a simple implementation of AES (the US government's Advanced Encryption Standard,
aka "Rijndael"), written in C for speed.  You can read more on the
[Wikipedia AES Page](http://en.wikipedia.org/wiki/Advanced_Encryption_Standard).
The algorithm itself was extracted from work by Christophe Devine for the open source Netcat clone
[sbd](http://www.cycom.se/dl/sbd). 

This code supports the main features of AES, specifically:

- 128, 192, and 256-bit ciphers
- Electronic Codebook (ECB) mode only - *see* *Security* *Note*
- Encrypted blocks are padded at 16-bit boundaries ([read more on padding](http://www.di-mgt.com.au/cryptopad.html#whatispadding))

You can read specifics about AES-ECB in the IPSec-related [RFC 3602](http://www.rfc-archive.org/getrfc.php?rfc=3602).

### Example

Simple encryption/decryption:

    require 'fast-aes'

    # key can be 128, 192, or 256 bits
    key = '42#3b%c$dxyT,7a5=+5fUI3fa7352&^:'

    aes = FastAES.new(key)

    text = "Hey there, how are you?"

    data = aes.encrypt(text)

    puts aes.decrypt(data)   # "Hey there, how are you?"

Pretty simple, jah?

## Why AES?

### SSL vs AES

I'm going to guess you're using Ruby with Rails, which means you're doing 90+% web development.
In that case, if you need security, SSL is the obvious choice (and the right one).

But there will probably come a time, padawan, when you need a couple backend servers to talk -
maybe job servers, or an admin port, or whatever.  Maybe even a simple chat server.

You can setup SSL certificates for this if you want it to be time-consuming to maintain.
Or you can directly use an encryption algorithm, such as AES.  Setting up an SSH tunnel is another
good alternative, if you control both systems.  I think it's easier to configure encryption keys
as part of your application, rather than having to mess with each individual system, but that's me.

For more information on how SSL/AES/RC4/TLS all interact,
[read this article on SSL and AES](http://luxsci.com/blog/256-bit-aes-encryption-for-ssl-and-tls-maximal-security.html)

### AES vs Other Encryption Standards

There are a bizillion (literally!) different encryption standards out there.  If you have
a PhD, and can't find a job, writing an encryption algorithm is a good thing to put on your resume -
on the outside chance that someone will hire you and use it.  If you don't possess the talent to
write an encryption standard, you can spend hours trying to crack one - for similar reasons.  As a
result, of the many encryption alternatives, most are either (a) cracked or (b) covered by patents.

Personally, when it comes to encryption, I think choosing what the US government chooses is a decent
choice.  They tend to be "security conscious."

## Author

Original AES C reference code by Christophe Devine.  Thanks Christophe!

This gem copyright (c) 2010-2011 [Nate Wiger](http://nateware.com).  Released under the MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
