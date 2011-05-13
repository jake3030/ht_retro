# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
gem "hoptoad_notifier"
require "ht_retro/version"

Gem::Specification.new do |s|
  s.name        = "ht_retro"
  s.version     = Hoptoad::Retro::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "ht_retro"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "rails", "~> 3.0.6"
  s.add_dependency "hoptoad_notifier", "~> 2.3"
  s.add_development_dependency 'rspec', '~> 2.5'
  
end
