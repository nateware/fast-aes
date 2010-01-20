
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../ext/#{RUBY_PLATFORM}"

describe 'FastAES' do
  before :all do
    puts "building extension..."
    # Build our extension each time
    Dir.chdir("#{File.dirname(__FILE__)}/../ext") do
      system "ruby extconf.rb"
      system "make clean"
      system "make && make install RUBYARCHDIR=#{RUBY_PLATFORM}"
    end

    require 'fast-aes'
  end

  it "should run the README duh" do
    require 'fast-aes'

    # key can be 128, 192, or 256 bits
    key = '42#3b%c$dxyT,7a5=+5fUI3fa7352&^:'
    aes = FastAES.new(key)
    text = "Hey there, how are you?"
    data = aes.encrypt(text)
    aes.decrypt(data).should == text   # "Hey there, how are you?"
  end

  it "should accept 128, 192, and 256-bit keys" do
    [128, 192, 256].each do |bits|
      key = 'a' * (bits/8)
      aes = FastAES.new(key)
      aes.key.should == key
    end
  end
  
  it "should raise an exception is the key isn't in the accepted range" do
    lambda{FastAES.new('key')}.should raise_error  # 24-bit
    lambda{FastAES.new('keykeyke')}.should raise_error # 64-bit
    lambda{FastAES.new('keykeykeykeykeykeykeykeykeykeykey')}.should raise_error # 264-bit
  end

  it "should encrypt and decrypt messages (what a concept)" do
    phrases = [
      'Hey there, how are you?',
      'You know, encryption is just so gosh-darned cool I wish I had a girlfriend to tell about it!!',
      'A subject for a great poet would be God\'s boredom after the seventh day of creation.',
      'The individual has always had to struggle to keep from being overwhelmed by the tribe. If you try it, '+
        'you will be lonely often, and sometimes frightened. But no price is too high to pay for the privilege of owning yourself.',
      'But although all our knowledge begins with experience, it does not follow that it arises from experience.',
      'Some with nulls\x00in-between\x00\x00 you know'
    ]

    phrases.each do |text|
      [128, 192, 256].each do |bits|
        key = 'a' * (bits/8)
        aes = FastAES.new(key)
        aes.key.should == key
        data = aes.encrypt(text)
        aes.decrypt(data).should == text
      end
    end
  end
  
  it "should have a different encoding based on the key length" do
    aes_1 = FastAES.new '12345678901234567890123456789012'
    aes_2 = FastAES.new '123456789012345678901234'
    aes_3 = FastAES.new '1234567890123456'
    text  = "So long and thanks for all the fish"
    secret_1, secret_2, secret_3 = aes_1.encrypt(text), aes_2.encrypt(text), aes_3.encrypt(text)
    [secret_1, secret_2, secret_3].each do |secret|
      ([secret_1, secret_2, secret_3] - [secret]).each{|message| message.should_not == secret}
    end
  end
  
end