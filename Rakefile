require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'

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
  r.rdoc_files.exclude('lib/generators/**/*')
end

namespace :spec do
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts = %w{--text-report --sort coverage}
    t.rcov_opts << %w{--exclude gems\/,spec\/}
  end
end
