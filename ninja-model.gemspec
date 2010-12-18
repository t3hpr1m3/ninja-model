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
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = s.name

  s.files         = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_paths = %w(lib)

  s.add_development_dependency 'rspec', '~> 2.0.1'
  s.add_development_dependency 'mocha', '~> 0.9.8'
  s.add_development_dependency 'rcov',  '~> 0.9.9'
end
