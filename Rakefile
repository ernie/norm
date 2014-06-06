require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

task :default => :test

namespace :test do
  task :integration do
    ENV['INTEGRATION'] = 'true'
    task(:test).execute
  end
end

task :console do
  require 'irb'
  require 'irb/completion'
  require 'norm'
  ARGV.clear
  Norm.init!('primary' => {:user=> 'norm_test'})
  IRB.start
end
