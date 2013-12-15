class CreatePostsTables < ActiveRecord::Migration
  def up
    create_table(:writers, :force => true) do |t|
      t.string :name, :null => false

      t.timestamps
    end

    create_table(:translated_posts) do |t|
      t.string :title, :null => false
      t.string :content, :null => false
      t.integer :post_id, :null => false
      t.string :language, :null => false, :limit => 2
      t.integer :writer_id

      t.timestamps
    end

    create_table(:posts) do |t|
      t.integer :writer_id

      t.timestamps
    end
  end

  def down
    drop_table(:writers)
    drop_table(:translated_posts)
    drop_table(:posts)
  end
end

CreatePostsTables.migrate(:up)

class Author < ActiveRecord::Base
  validates :name, :presence => true
end

class TranslatedPost < ActiveRecord::Base
  attr_accessible :title, :content, :language

  before_create :duplicate_writer_id

  protected

  def duplicate_writer_id
    self.writer_id = post.writer_id
  end
end

class Post < ActiveRecord::Base

  belongs_to  :writer

  translatable do
    field  :title, :as => :translated_title, :presence => true, :uniqueness => true
    field  :content, :presence => true
    class_name 'TranslatedPost'
    reflection_name :post
    foreign_key :post_id
    locale_key :language
  end

  accepts_nested_attributes_for :translations, :current_translation
  attr_accessible :translations_attributes, :current_translation_attributes
  attr_accessible :writer_id, :writer
end