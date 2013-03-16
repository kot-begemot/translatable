require 'translatable/active_record'
  
if defined?(Rails)
  require 'translatable/engine'

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.extend Translatable::ActiveRecord if defined?(I18n)
  end
else
  begin 
    require 'active_record'
    require 'i18n'
      
    ActiveRecord::Base.extend Translatable::ActiveRecord
  rescue LoadError
    $stderr.puts "Warning: Translatable is not loaded"
  end
end
