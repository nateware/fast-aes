
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

  it "should accept 128, 192, and 256-bit keys" do
    [128, 192, 256].each do |bits|
      key = 'a' * (bits/8)
      aes = FastAES.new(key)
      aes.key.should == key
    end
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
  
end

