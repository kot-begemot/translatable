# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "translatable"
  gem.homepage = "http://github.com/kot-begemot/translatable"
  gem.license = "MIT"
  gem.summary = %Q{An esay way to manage the translations for datamapper}
  gem.description = %Q{This game was build to make whole proccess of working with translation for DM to be almost invisble. That was THE AIM.}
  gem.email = "max@studentify.nl"
  gem.authors = ["E-Max"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new

