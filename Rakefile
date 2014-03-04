require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

task :default => :test

task :console do
  require 'irb'
  require 'irb/completion'
  require 'norm'
  ARGV.clear
  Norm.init!
  IRB.start
end
