# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
gem "hoptoad_notifier"
require "ht_retro/version"

Gem::Specification.new do |s|
  s.name        = "ht_retro"
  s.version     = Hoptoad::Retro::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jake Varghese"]
  s.email       = ["jake@flvorful.com"]
  s.homepage    = ""
  s.summary     = %q{HT retro}
  s.description = %q{if you need it you will know :)}

  s.rubyforge_project = "ht_retro"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "hoptoad_notifier", "~> 2.4.9"
  s.add_development_dependency 'rspec', '~> 2.5'
  
end
