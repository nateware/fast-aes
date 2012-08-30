require 'bacon'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../ext/#{RUBY_PLATFORM}")

require 'fast_aes'

Bacon.summary_at_exit
if $0 =~ /\brspec$/
  raise "\n===\nThese tests are in bacon, not rspec.  Try: bacon #{ARGV * ' '}\n===\n"
end

require 'digest'

def random_key(len)
  x = ''
  (len/8).times do
    c = rand(256) until !c.nil? && c != 0
    x << c.chr
  end
  x
end

# Some sample keys
TEST_KEYS = [
  random_key(128),
  random_key(128),
  random_key(192),
  random_key(192),
  random_key(256),
  random_key(256)
]

LOREM_IPSUM = <<-EndLorem
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin posuere posuere pretium. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sit amet sem vitae nibh scelerisque commodo. Sed nec leo ante, non porttitor augue. Donec convallis lobortis pellentesque. Pellentesque commodo, eros consectetur malesuada accumsan, libero risus pulvinar velit, a tempor quam ligula vitae nisi. In commodo venenatis quam vitae interdum. Aliquam ipsum turpis, tempus tempus mattis nec, dignissim fermentum nibh. Pellentesque vulputate congue nisl vel dignissim.

Donec diam erat, sodales et vehicula ac, ullamcorper eget lectus. Donec auctor nisl ac nisi venenatis scelerisque. Nunc aliquet ultricies nisl ac adipiscing. Cras at nibh non diam ultricies iaculis. Donec justo diam, porttitor nec porta sit amet, molestie ut augue. Nullam tristique nisl mollis est scelerisque sagittis. Sed nec mi ac nunc consequat tristique eu nec purus. Curabitur congue feugiat adipiscing. Aenean adipiscing aliquam imperdiet. Sed fringilla volutpat dui ac semper. Nullam dapibus mauris in nulla pretium sit amet laoreet libero dignissim. Maecenas et elit dolor, id tincidunt felis. Morbi adipiscing ligula quis lorem laoreet consectetur. Praesent a eros ac tortor interdum interdum ac malesuada magna.

Fusce in lorem luctus odio faucibus accumsan vitae a odio. Aliquam ullamcorper neque eu odio elementum sit amet blandit mauris varius. Quisque a sem lectus, quis venenatis urna. Donec auctor odio nec elit lacinia vestibulum. Nullam porttitor blandit fringilla. Duis justo erat, semper vel elementum sit amet, ultrices sed libero. Aliquam semper urna rutrum felis vulputate egestas. Aliquam ut est eget lorem egestas rutrum. In vel tellus nulla. Etiam nec sem libero. Duis adipiscing euismod ligula vitae consequat. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;

Vestibulum suscipit, est vel dignissim mattis, eros odio scelerisque justo, id ultricies est tortor nec nibh. Fusce pellentesque vehicula leo vel interdum. Curabitur vitae quam dolor. In bibendum vestibulum nibh, vitae blandit felis vehicula in. Praesent imperdiet fermentum sapien. Proin aliquet consectetur turpis non bibendum. Morbi ultrices tempus elementum. Aliquam bibendum lobortis porttitor.

Aenean et feugiat metus. Aliquam scelerisque augue id ipsum facilisis nec blandit odio molestie. Maecenas tincidunt dignissim elit, quis blandit lectus dictum quis. Sed blandit lorem eget ante egestas non consectetur risus ultricies. Nam a purus et urna bibendum posuere eu commodo sem. Praesent rhoncus vulputate lacus a suscipit. Vivamus eros est, gravida sodales consectetur imperdiet, luctus nec lorem. Mauris lacinia, diam nec adipiscing gravida, felis dui tincidunt purus, sed ultricies neque erat et lacus. Quisque quis ligula tortor. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nulla facilisi. Phasellus in nisl odio. Cras porttitor varius viverra. Nullam arcu erat, semper fermentum blandit ac, vestibulum molestie risus. Donec at lectus sapien.
EndLorem

LOREM_PARAS = LOREM_IPSUM.split(/\n+/)

