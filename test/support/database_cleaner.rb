require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

module OrmSetup
  def before_setup
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
  end
end
