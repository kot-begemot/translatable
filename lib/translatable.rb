require 'translatable/active_record'
  
if defined?(Rails)
  require 'translatable/engine'

  ActiveSupport.on_load(:active_record) do
    ActiveSupport.on_load(:i18n) do
      ActiveRecord::Base.extend Translatable::ActiveRecord
    end
  end
else
  require 'active_record'
  require 'i18n'
  
  ActiveRecord::Base.extend Translatable::ActiveRecord
end
