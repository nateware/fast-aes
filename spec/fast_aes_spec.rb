
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}"
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../ext/#{RUBY_PLATFORM}"

require 'bit_field'

describe 'FastAES' do
  before :all do
    puts "building extension..."
    # Build our extension each time
    Dir.chdir("#{File.dirname(__FILE__)}/../ext") do
      system "ruby extconf.rb"
      system "make clean"
      system "make"
      system "make install RUBYARCHDIR=#{RUBY_PLATFORM}"
    end

    require 'fast_aes'
  end

  it "should accept 128, 192, and 256-bit keys" do
    [128, 192, 256].each do |bits|
      key = 'a' * (bits/8)
      aes = FastAES.new(key)
      aes.key.should == key
    end
  end
end

