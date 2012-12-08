require 'logger'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ':memory:'
)

ActiveRecord::Migration.verbose = $VERBOSE
if $VERBOSE
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
