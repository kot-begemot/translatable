class CreateNewsTables < ActiveRecord::Migration
  def up
    create_table(:authors) do |t|
      t.string :name, :null => false

      t.timestamps
    end

    create_table(:translated_news) do |t|
      t.string :title, :null => false
      t.string :content, :null => false
      t.integer :origin_id, :null => false
      t.string :locale, :null => false, :limit => 2

      t.timestamps
    end

    create_table(:news) do |t|
      t.integer :author_id

      t.timestamps
    end
  end

  def down
    drop_table(:authors)
    drop_table(:translatable_news)
    drop_table(:news)
  end
end

CreateNewsTables.migrate(:up)

class Author < ActiveRecord::Base
  validates :name, :presence => true
end

class TranslatedNews < ActiveRecord::Base
  validates :title, :content, :presence => true
  validates :title, :uniqueness => true

  attr_accessible :title, :content, :locale, :origin_id
end

class News < ActiveRecord::Base

  belongs_to  :author

  translatable do
    field  :title
    field  :content
  end

  attr_accessible :author_id, :author
end