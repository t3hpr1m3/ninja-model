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
  s.summary     = %q{Makes custom backends more ActiveRecord-like}
  s.summary     = %q{Makes custom backends more ActiveRecord-like, allowing for interoperability.}

  s.files         = Dir["{lib}/**/*", "[A-Z]*"] - ["Gemfile.lock"]
  s.require_paths = %w(lib)

  s.add_dependency 'rails', '3.0.3'

  s.add_development_dependency 'rspec',     '~> 2.0.1'
  s.add_development_dependency 'mocha',     '~> 0.9.8'
  s.add_development_dependency 'rcov',      '~> 0.9.9'
  s.add_development_dependency 'cucumber',  '~> 0.9.4'
  s.add_development_dependency 'nokogiri',  '~> 1.4.4'

  s.rubyforge_project = s.name
  s.required_rubygems_version = '>= 1.3.4'
end
