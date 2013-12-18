source "http://rubygems.org"

gem "activerecord", ">= 4.0.0"
gem "activesupport", :require => false
gem "i18n"

group :debug do
  gem "byebug", :platform => :ruby_20
  #gem "debugger", "~> 1.2.2", :platform => :ruby_19
  #gem "ruby-debug", :platform => :ruby_18
end

group :development, :test do
  gem "jeweler", "~> 1.8.0"
end

group :debug, :test do
  gem "yard"  
  gem "redcarpet"
end

group :test do
  gem "sqlite3"
  gem "database_cleaner"
  gem "protected_attributes", "~> 1.0.5"

  gem "rails"

  gem "test-unit"
  gem "shoulda"

  gem "turn"
end