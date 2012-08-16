require 'rubygems'
require 'bundler'
if RUBY_VERSION >= '1.9.0'
  require "debugger"
else
  require 'ruby-debug'
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'translatable'

require File.expand_path("support/active_record", File.dirname(__FILE__))
require File.expand_path("support/database_cleaner", File.dirname(__FILE__))

class Test::Unit::TestCase
  include OrmSetup
end
