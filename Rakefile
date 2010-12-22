require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

desc 'Run specs with documentation format'
RSpec::Core::RakeTask.new(:specd) do |t|
  t.verbose = false
  t.rspec_opts = '--format d'
end

Rake::RDocTask.new do |r|
  r.rdoc_dir = 'doc/html'
  r.main = "README.md"
  r.rdoc_files.include('README.md', 'lib/**/*.rb')
end

namespace :spec do
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts = %w{--text-report --sort coverage}
    t.rcov_opts << %w{--exclude gems\/,spec\/}
  end
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress"
end
