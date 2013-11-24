require 'bundler'
require 'test/unit'
require "shoulda-context"
require "i18n"

begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
    add_filter "/vendor/"
  end
rescue LoadError
  $stderr.puts "Simplecov is skipped"
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'translatable'

require File.expand_path("support/active_record", File.dirname(__FILE__))
require File.expand_path("support/database_cleaner", File.dirname(__FILE__))

class Test::Unit::TestCase
  include OrmSetup

  setup do
    before_setup
    ::I18n.locale = ::I18n.default_locale
  end

  teardown do
    after_teardown
  end
end
