#
# Comparison of AES encryption libraries
#

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../ext/#{RUBY_PLATFORM}"

require 'benchmark'
require 'fast_aes'
require 'crypt/rijndael'

CHARS = ('A'..'z').collect{|x| x.to_s}

def random_key(bits)
  str = ''
  (bits/8).times do
    str += CHARS[rand(CHARS.length)]
  end
  str
end

Benchmark.bmbm(20) do |bm|
  bm.report 'crypt/rijndael' do
    1000.times do
      rijndael = Crypt::Rijndael.new(random_key(256))
      plainBlock = "ABCDEFGH12345678"
      encryptedBlock = rijndael.encrypt_block(plainBlock)
      decryptedBlock = rijndael.decrypt_block(encryptedBlock)
    end
  end

  bm.report 'fast_aes' do
    10000.times do
      aes = FastAES.new(random_key(256))
      plainBlock = "ABCDEFGH12345678"
      encryptedBlock = aes.encrypt(plainBlock)
      decryptedBlock = aes.decrypt(encryptedBlock)
    end
  end
  
end