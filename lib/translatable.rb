module Translatable
end

require "translatable/base"

if defined?(Rails)
  require 'translatable/engine'

  ActiveSupport.on_load(:active_record) do
    require 'translatable/orm/active_record'
    ActiveRecord::Base.extend Translatable::ActiveRecord 
  end
else
  if defined?(ActiveRecord)
    require 'translatable/orm/active_record'
    ActiveRecord::Base.extend Translatable::ActiveRecord
  end
end