require 'rake/testtask'
require 'bundler/gem_tasks'

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  Dir.chdir('test/unit')
  t.libs << "test"
  t.test_files = FileList['*_test.rb']
end

task :default => :test