require 'bundler/setup'
require "bundler/gem_tasks"
Bundler.require(:development)

require 'fileutils'
require "rake/testtask"

# Test Task
Rake::TestTask.new do |t|
    t.libs << 'lib' << 'test'
    t.test_files = FileList[ARGV[1] ? ARGV[1] : 'test/**/*_test.rb']
    # t.warning = true
    # t.verbose = true
end