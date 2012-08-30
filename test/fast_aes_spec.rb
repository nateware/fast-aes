require File.expand_path('spec_helper', File.dirname(__FILE__))

# key can be 128, 192, or 256 bits
describe "FastAES" do
  it "should encrypt/decrypt README" do
    key = '42#3b%c$dxyT,7a5=+5fUI3fa7352&^:'

    aes = FastAES.new(key)

    text = "Hey there, how are you?"

    data = aes.encrypt(text)

    text.should == aes.decrypt(data)   # "Hey there, how are you?"
  end

  it "should fail on bad keys" do
    e = nil
    begin
      FastAES.new("too short")
    rescue => e
    end
    e.should.be.kind_of ArgumentError
  end

  it "should handle different key lengths" do
    TEST_KEYS.each do |key|
      aes = FastAES.new(key)
      data = aes.encrypt(LOREM_IPSUM)
      text = aes.decrypt(data)
      text.should == LOREM_IPSUM
    end
  end
end

