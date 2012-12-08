# encoding: utf-8
require 'test_helper'
require 'support/models/news'
require 'support/models/posts'
require 'support/models/messages'

class TranslatableTest < Test::Unit::TestCase
  context "Translatable hash" do
    should "Define default" do
      th = News.instance_variable_get :@translatable

      assert_kind_of Hash, th
      assert th.has_key?(:properties)
    end

    should "Has dafault model" do
      assert_equal ::TranslatableNews, News.send(:translatable_model_prepared, 'TranslatableNews')
    end
  end

  context "Translatable model preparation" do
    should "Accept constant" do
      assert_equal ::TranslatableNews, News.send(:translatable_model_prepared, ::TranslatableNews)
    end

    should "Accept string" do
      assert_equal ::TranslatableNews, News.send(:translatable_model_prepared, "TranslatableNews")
    end

    should "Accept symbol" do
      assert_equal ::TranslatableNews, News.send(:translatable_model_prepared, :TranslatableNews)
    end
  end

  context "Instance" do
    should "Respond to translatable methods" do
      news = News.new

      assert news.respond_to?(:title), "title methods is missing for News instance"
      assert news.respond_to?(:content), "content methods is missing for News instance"
    end

    should "Creates without translation" do
      news = News.create

      assert news.persisted?
      assert_nil TranslatableNews.last
    end

    should "Have no other translation" do
      news = News.create :translations_attributes => [{ :title => "Заголовок", :content => "Содержание", :locale => "ru"}]

      assert news.persisted?

      t_news = TranslatableNews.last
      assert_equal [t_news], news.other_translations
      ::I18n.locale = :ru
      assert_equal [], news.other_translations
      ::I18n.locale = ::I18n.default_locale
    end

    should "Provide errors on creation" do
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => ""}]

      assert news.new_record?

      assert_equal ["Translations locale can't be blank"], news.errors.full_messages

      news.translations.each do |t|
        assert t.new_record?
      end
    end
  end

  context "Translatable instance" do
    should "Respond to translatable methods" do
      news = TranslatableNews.new

      assert news.respond_to?(:title), "Title method is missing for TranslatableNews instance"
      assert news.respond_to?(:content), "Content method is missing for TranslatableNews instance"
    end

    should "Respond to methods related to origin" do
      news = TranslatableNews.new

      assert news.respond_to?(:locale), "Locale method is missing for TranslatableNews instance"
      assert news.respond_to?(:origin_id), "Origin methods is missing for TranslatableNews instance"
      assert news.respond_to?(:origin), "Origin methods is missing for TranslatableNews instance"
    end
  end

  context "Creation with translation" do
    should "Assign to origin" do
      news = News.create
      t_news = TranslatableNews.create :title => "Заголовок", :content => "Содержание", :locale => "ru", :origin_id => news.id

      assert t_news.persisted?

      t_news = TranslatableNews.last
      assert_equal news.id, t_news.origin_id
      assert_equal "Заголовок", t_news.title
      assert_equal "Содержание", t_news.content
      assert_equal "ru", t_news.locale
    end

    should "Create translation on origin creation" do
      news = News.create :translations_attributes => [{ :title => "Заголовок", :content => "Содержание", :locale => "ru"}]

      assert news.persisted?

      t_news = TranslatableNews.last
      assert_equal news.id, t_news.origin_id.to_i
      assert_equal "Заголовок", t_news.title
      assert_equal "Содержание", t_news.content
      assert_equal "ru", t_news.locale
    end

    should "Create multiple translations" do
      news = News.create :translations_attributes => [{ :title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?

      t_news = TranslatableNews.first
      assert_equal news.id, t_news.origin_id.to_i
      assert_equal "Заголовок", t_news.title
      assert_equal "Содержание", t_news.content
      assert_equal "ru", t_news.locale

      t_news = TranslatableNews.last
      assert_equal news.id, t_news.origin_id.to_i
      assert_equal "Resent News", t_news.title
      assert_equal "That is where the text goes", t_news.content
      assert_equal "en", t_news.locale
    end
  end

  context "Current translation" do
    should "Set default translation" do
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?

      assert_equal "Resent News", news.title
      assert_equal "That is where the text goes", news.content
    end
    
    should "Been set equal to current locale" do
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?

      ::I18n.locale = :ru
      assert_equal "Заголовок", news.title
      assert_equal "Содержание", news.content
      ::I18n.locale = ::I18n.default_locale
    end
    
    should "Not been set if unavailable" do
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?

      ::I18n.locale = :de
      assert_nil news.title
      assert_nil news.content
    end

    should "Be be switched on locale switching" do
      news = News.create :translations_attributes => [{:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?

      t_news = news.translations.create :title => "Заголовок", :content => "Содержание",:locale => "ru"
      assert t_news.persisted?

      ::I18n.locale = ::I18n.default_locale

      assert_equal "Resent News", news.title
      assert_equal "That is where the text goes", news.content

      ::I18n.locale = :ru

      assert_equal "Заголовок", news.title
      assert_equal "Содержание", news.content
    end
  end

  should "Add translation to existing record" do
    news = News.create :translations_attributes => [{:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

    assert news.persisted?

    t_news = news.translations.create :title => "Заголовок", :content => "Содержание",:locale => "ru"

    assert t_news.persisted?
    assert t_news.persisted?
  end

  should "Define validations" do
    post = Post.create :translations_attributes => [{:title => "Заголовок",:content => "Содержание", :locale => "ru"},
      {:title => "Resent Post", :content => "That is where the text goes", :locale => "en"}]
    assert post.persisted?, "Message had errors: #{post.errors.inspect}"

    post = Post.create :translations_attributes => [{:content => "Содержание", :locale => "ru"},
      {:title => "Resent Post 2", :content => "That is where the text goes", :locale => "en"}]
    
    assert post.new_record?, "Message had errors: #{post.errors.full_messages.inspect}"
    assert_equal ["Translations title can't be blank"], post.errors.full_messages

    post = Post.create :translations_attributes => [{:title => "Заголовок 2", :locale => "ru"},
      {:title => "Resent Post 3", :content => "That is where the text goes", :locale => "en"}]

    assert post.new_record?, "Message had errors: #{post.errors.full_messages.inspect}"
    assert_equal ["Translations content can't be blank"], post.errors.full_messages

    post = Post.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
      {:title => "Resent Post 3", :content => "That is where the text goes", :locale => "en"}]

    assert post.new_record?, "Message had errors: #{post.errors.full_messages.inspect}"
    assert_equal ["Translations title has already been taken"], post.errors.full_messages
  end

  def test_origin_is_owerwrittent
    post = Post.create :translations_attributes => [{:title => "Заголовок",:content => "Содержание", :locale => "ru"},
      {:title => "Resent Post", :content => "That is where the text goes", :locale => "en"}]
    assert post.persisted?, "Message had errors: #{post.errors.inspect}"

    assert_not_equal post.object_id, post.translations.first.post.object_id
  end

  should "Accept aliases for fileds" do
    post = Post.create :translations_attributes => [{:title => "Заголовок",:content => "Содержание", :locale => "ru"},
      {:title => "Resent Post", :content => "That is where the text goes", :locale => "en"}]
    assert post.persisted?, "Message had errors: #{post.errors.inspect}"

    assert_equal "Resent Post", post.translated_title

    ::I18n.locale = :ru
    assert_equal "Заголовок", post.translated_title
    ::I18n.locale = ::I18n.default_locale
  end

  context "Mass assigment" do
    should "Be available to mass assigment by default" do
      tp = TranslatableNews.new( :title => "Resent News", :content => "That is where the text goes", :locale => "en", :origin_id => 1)

      assert_equal "Resent News", tp.title
      assert_equal "That is where the text goes", tp.content
      assert_equal "en", tp.locale
      assert_equal 1, tp.origin_id
    end

    should "Protect internal fields on desire" do
      tm = TranslatedMessage.new( :title => "Resent Post", :content => "That is where the text goes", :locale => "en", :message_id => 1)

      assert_equal "Resent Post", tm.title
      assert_equal "That is where the text goes", tm.content
      assert_equal nil, tm.locale
      assert_equal nil, tm.message_id
    end

    should "Allow multiple assigment rules" do
      tm = TranslatedMessage.new( {:title => "Resent Post", :content => "That is where the text goes", :locale => "en", :message_id => 1}, :as => :editor)

      assert_equal "Resent Post", tm.title
      assert_equal "That is where the text goes", tm.content
      assert_equal "en", tm.locale
      assert_equal nil, tm.message_id
    end
  end
end
