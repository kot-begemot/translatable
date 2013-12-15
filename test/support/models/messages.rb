class CreateMessagesTables < ActiveRecord::Migration
  def up
    create_table(:writers, :force => true) do |t|
      t.string :name, :null => false

      t.timestamps
    end

    create_table(:message_translations) do |t|
      t.string  :title, :null => false
      t.string  :content, :null => false
      t.integer :origin_id, :null => false
      t.string  :locale, :null => false, :limit => 2
      t.integer :writer_id

      t.timestamps
    end

    create_table(:messages) do |t|
      t.integer :writer_id

      t.timestamps
    end
  end

  def down
    drop_table(:writers)
    drop_table(:message_translations)
    drop_table(:messages)
  end
end

CreateMessagesTables.migrate(:up)

class Author < ActiveRecord::Base
  validates :name, :presence => true
end

class MessageTranslation < ActiveRecord::Base
  attr_accessible :title, :content
  attr_accessible :title, :content, :locale, :as => :editor

  before_validation :set_default_locale, :if => :writer_id
  before_create :duplicate_writer_id, :unless => :writer_id

  protected

  def set_default_locale
    self.locale ||= ::I18n.locale
  end

  def duplicate_writer_id
    self.writer_id = message.writer_id
  end
end

class Message < ActiveRecord::Base

  belongs_to  :writer

  translatable do
    field  :title, :presence => true, :uniqueness => true
    field  :content, :presence => true
    class_name 'MessageTranslation'
    reflection_name :message
  end

  accepts_nested_attributes_for :translations, :current_translation
  attr_accessible :translations_attributes, :current_translation_attributes
  attr_accessible :writer_id, :writer
end