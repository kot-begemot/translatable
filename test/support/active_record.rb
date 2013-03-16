require 'logger'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ':memory:'
)

$VERBOSE ||= ENV['VERBOSE'] == 'true'

ActiveRecord::Migration.verbose = $VERBOSE
if $VERBOSE
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
