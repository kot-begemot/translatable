require "test_helper"
require "rails"
require 'rails/generators'
require "generators/translatable/model_generator"

class ModelGeneratorTest < Rails::Generators::TestCase
  tests Translatable::Generators::ModelGenerator
  destination File.expand_path("../../../tmp", __FILE__)
  setup :prepare_destination
  teardown :cleanup_destination_root

  should "Create required files with default options" do
    run_generator %w(article title:string content:string)
    assert_file "app/models/article.rb", <<CONTENT
class Article < ActiveRecord::Base
  translatable do
    field :title, :presence => true#, :uniqueness => true
    field :content, :presence => true#, :uniqueness => true
    #class_name 'TranslatedArticle'
    #reflection_name :article
    #foreign_key :origin_id
    #locale_key :locale
  end
end
CONTENT
    assert_migration "db/migrate/create_articles.rb", <<CONTENT
class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|

      t.timestamps
    end
  end
end
CONTENT
  end

  should "Create required files with special options" do
    run_generator %w(article title:string content:string --translated_model=ArticleTranslation --origin=post --locale=language)
    assert_file "app/models/article.rb", <<CONTENT
class Article < ActiveRecord::Base
  translatable do
    field :title, :presence => true#, :uniqueness => true
    field :content, :presence => true#, :uniqueness => true
    class_name 'ArticleTranslation'
    reflection_name :post
    #foreign_key :origin_id
    locale_key :language
  end
end
CONTENT
    assert_migration "db/migrate/create_articles.rb", <<CONTENT
class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|

      t.timestamps
    end
  end
end
CONTENT
  end

  should "Inject into existing class" do
    create_model_file
    run_generator %w(article title:string content:string)
    
    assert_file "app/models/article.rb", <<CONTENT
class Article < ActiveRecord::Base
  translatable do
    field :title, :presence => true#, :uniqueness => true
    field :content, :presence => true#, :uniqueness => true
    #class_name 'TranslatedArticle'
    #reflection_name :article
    #foreign_key :origin_id
    #locale_key :locale
  end
  attr_accessor :created_at, :updated_at
end
CONTENT
    assert_no_migration "db/migrate/create_articles.rb"
  end

  protected

  def create_model_file
    FileUtils.mkdir_p File.join(destination_root, "app", "models")
    f = File.open(File.join(destination_root, "app", "models", "article.rb"), "w+")
    f.write <<CONTENT
class Article < ActiveRecord::Base
  attr_accessor :created_at, :updated_at
end
CONTENT
    f.close
  end

  def cleanup_destination_root
    FileUtils.rm_rf destination_root
  end
end