source "http://rubygems.org"

gem "activerecord"
gem "activesupport", :require => false
gem "i18n"

group :debug do
  gem "simplecov", ">= 0.6.0", :platform => :ruby_19
  gem "debugger", "~> 1.1.3", :platform => :ruby_19
  gem "ruby-debug", :platform => :ruby_18
end

group :development do
  gem "yard"
  gem "jeweler", ">= 1.6.0"
  gem "bundler", ">= 1.2.0"
end

group :test do
  gem "rails"
  gem "test-unit"
  gem "shoulda"

  gem "database_cleaner"
  gem "sqlite3"
end
