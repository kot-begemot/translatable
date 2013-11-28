module Translatable
end

require "translatable/base"

unless Gem::Specification.find_all_by_name("rails").empty?
  require 'translatable/engine'

  ActiveSupport.on_load(:active_record) do
    require 'translatable/orm/active_record'
    ActiveRecord::Base.extend Translatable::ActiveRecord 
  end
else
  if Gem::Specification.find_by_name("active_record")
    require 'active_record'
    require 'translatable/orm/active_record'
    
    ActiveRecord::Base.extend Translatable::ActiveRecord
  end
end