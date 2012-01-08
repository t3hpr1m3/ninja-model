#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'
require 'yard'


RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
  t.pattern = 'spec/**/*_spec.rb'
end

YARD::Rake::YardocTask.new do |t|
  t.options = ['--exclude', 'generators']
end

Bundler::GemHelper.install_tasks
