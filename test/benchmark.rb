#
# Comparison of AES encryption libraries
#

require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'benchmark'
require 'openssl'

Benchmark.bmbm(20) do |bm|
  bm.report 'openssl' do
    10000.times do
      cipher = OpenSSL::Cipher.new("AES-256-CBC")
      cipher.encrypt
      key = cipher.random_key
      iv  = cipher.random_iv
      enc = cipher.update(LOREM_IPSUM) + cipher.final

      cipher = OpenSSL::Cipher.new("AES-256-CBC")
      cipher.decrypt
      cipher.key = key
      cipher.iv  = iv
      dec = cipher.update(enc) + cipher.final

      raise "mismatch" unless dec == LOREM_IPSUM
    end
  end

  bm.report 'fast_aes' do
    10000.times do
      aes = FastAES.new(random_key(256))
      enc = aes.encrypt(LOREM_IPSUM)
      dec = aes.decrypt(enc)
      raise "mismatch" unless dec == LOREM_IPSUM
    end
  end
  
end
