#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'
require 'yard'

#task :prepare_db do
#  db_root = File.join(File.expand_path('../', __FILE__), 'spec', 'db')
#  db_file = File.join(db_root, 'test.sqlite3')
#  sh "rm #{db_file}" if File.exists?(db_file)
#  sh %Q{sqlite3 "#{db_file}" "create table a (a integer); drop table a;"}
#end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
  t.pattern = 'spec/**/*_spec.rb'
end

YARD::Rake::YardocTask.new do |t|
  t.options = ['--exclude', 'generators']
end

Bundler::GemHelper.install_tasks
