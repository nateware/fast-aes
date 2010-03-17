spec = Gem::Specification.new do |s|
  s.name = 'fast-aes'
  s.version = '0.1.1'
  s.summary = "Fast AES implementation in C.  Works with Ruby 1.8 and 1.9"
  s.description = s.summary + '.'
  s.files = Dir['ext/**/*.{rb,c,h}'] + Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] + Dir['test/**/*.rb']
  s.extensions << 'ext/extconf.rb'
  s.require_path = 'lib'
  s.has_rdoc = true
  s.rubyforge_project = 'fast-aes'
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options << '--title' <<  'FastAES -- Fast AES implementation for Ruby in C'
  s.author = "Nate Wiger"
  s.email = "nate@wiger.org"
  s.homepage = "http://github.com/nateware/fast-aes"
end

