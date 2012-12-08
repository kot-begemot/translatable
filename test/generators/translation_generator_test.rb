require "test_helper"
require "rails"
require 'rails/generators'
require "generators/translatable/translation_generator"

class TranslationGeneratorTest < Rails::Generators::TestCase
  tests Translatable::Generators::TranslationGenerator
  destination File.expand_path("../../../tmp", __FILE__)
  setup :prepare_destination
  teardown :cleanup_destination_root

  should "Create required files (default)" do
    run_generator %w(article title:string content:string)
    assert_file "app/models/translatable_article.rb", <<CONTENT
class TranslatableArticle < ActiveRecord::Base
  # This class deals purely with translations themselves. Hence, any edition of
  # should be avoided.
  # In later gem version its existance might not be necessary.
  attr_accessible :title, :content
  #attr_protected :origin_id, :locale
end
CONTENT
    assert_migration "db/migrate/create_translatable_articles.rb", <<CONTENT
class CreateTranslatableArticles < ActiveRecord::Migration
  def change
    create_table :translatable_articles do |t|
      t.string :title
      t.string :content
      t.integer :origin_id
      t.string :locale

      t.timestamps
    end
  end
end
CONTENT
  end

  should "Create required files (with options)" do
    run_generator %w(article title:string content:string --prefix=Translation --origin=post --locale=language)
    assert_file "app/models/translation_article.rb", <<CONTENT
class TranslationArticle < ActiveRecord::Base
  # This class deals purely with translations themselves. Hence, any edition of
  # should be avoided.
  # In later gem version its existance might not be necessary.
  attr_accessible :title, :content
  #attr_protected :post_id, :language
end
CONTENT
    assert_migration "db/migrate/create_translation_articles.rb", <<CONTENT
class CreateTranslationArticles < ActiveRecord::Migration
  def change
    create_table :translation_articles do |t|
      t.string :title
      t.string :content
      t.integer :post_id
      t.string :language

      t.timestamps
    end
  end
end
CONTENT
  end

  protected

  def cleanup_destination_root
    FileUtils.rm_rf destination_root
  end
end