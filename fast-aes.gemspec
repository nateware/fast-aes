spec = Gem::Specification.new do |s|
  s.name = 'fast-aes'
  s.version = '0.1.2'
  s.summary = "Simple but LOW security AES gem - OBSOLETE"
  s.description = s.summary + '.'
  s.files = Dir['ext/**/*.{rb,c,h}'] + Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] + Dir['test/**/*.rb']
  s.extensions << 'ext/extconf.rb'
  s.require_path = 'lib'
  s.has_rdoc = true
  s.rubyforge_project = 'fast-aes'
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options << '--title' << s.summary
  s.author = "Nate Wiger"
  s.email = "nwiger@gmail.com"
  s.homepage = "http://github.com/nateware/fast-aes"
end

