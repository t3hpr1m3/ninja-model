# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ninja_model/version"

Gem::Specification.new do |s|
  s.name        = %q{ninja-model}
  s.version     = NinjaModel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = %q{Josh Williams}
  s.email       = %q{theprime@codingprime.com}
  s.homepage    = %q{http://github.com/t3hpr1m3/ninja-model.git}
  s.summary     = %q{Pseudo-ORM for Ruby}
  s.description = %q{Pseudo-ORM for Ruby/Rails with an ActiveRecord-like interface}

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n") - ["Gemfile.lock"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord', '~> 3.1.0'

  s.add_development_dependency 'rspec',     	'2.7.0'
  s.add_development_dependency 'mocha',     	'0.10.0'
  s.add_development_dependency 'rcov',      	'0.9.11'
  s.add_development_dependency 'nokogiri', 		'1.5.0'
  s.add_development_dependency 'guard-rspec',	'0.5.10'
  s.add_development_dependency 'libnotify',		'0.6.0'
end
