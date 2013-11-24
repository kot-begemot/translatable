# encoding: utf-8
require 'active_record'
require 'test_helper'
require 'support/models/news'
require 'support/models/posts'
require 'support/models/messages'

class ActiveRecordTest < Test::Unit::TestCase
  teardown do
    ::I18n.locale = ::I18n.default_locale
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
      assert_nil TranslatedNews.last
    end

    should "Change current translation" do
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?
      assert_equal TranslatedNews.last, news.current_translation
      assert_equal "en", news.current_translation.locale
      
      news.set_current_translation :ru
      assert_equal TranslatedNews.first, news.current_translation
      assert_equal "ru", news.current_translation.locale
    end

    should "Evaluate under translation" do
      test_runner = self
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert_equal "en", news.current_translation.locale

      news.with_locale(:ru) do
        test_runner.assert_equal "ru", news.current_translation.locale
      end
      assert_equal "en", news.current_translation.locale

      news.with_locale(:ru) do |n|
        test_runner.assert_equal "ru", n.current_translation.locale
      end
      assert_equal "en", news.current_translation.locale
    end

    should "Shortcut translation" do
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert_equal TranslatedNews.last, news.t(:en)
      assert_equal "en", news.t(:en).locale

      assert_equal TranslatedNews.first, news.t(:ru)
      assert_equal "ru", news.t(:ru).locale
    end

    should "Have no other translation" do
      news = News.create :translations_attributes => [{ :title => "Заголовок", :content => "Содержание", :locale => "ru"}]

      assert news.persisted?

      t_news = TranslatedNews.last
      assert_equal [t_news], news.other_translations
      
      news.set_current_translation :ru

      assert_equal [], news.other_translations
    end

    should "Have other translation" do
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?
      assert_equal [TranslatedNews.first], news.other_translations
      
      news.set_current_translation :ru
      assert_equal [TranslatedNews.last], news.other_translations
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
      news = TranslatedNews.new

      assert news.respond_to?(:title), "Title method is missing for TranslatedNews instance"
      assert news.respond_to?(:content), "Content method is missing for TranslatedNews instance"
    end

    should "Respond to methods related to origin" do
      news = TranslatedNews.new

      assert news.respond_to?(:locale), "Locale method is missing for TranslatedNews instance"
      assert news.respond_to?(:origin_id), "Origin methods is missing for TranslatedNews instance"
      assert news.respond_to?(:origin), "Origin methods is missing for TranslatedNews instance"
    end
  end

  context "Creation with translation" do
    should "Assign to origin" do
      news = News.create
      t_news = TranslatedNews.create :title => "Заголовок", :content => "Содержание", :locale => "ru", :origin_id => news.id

      assert t_news.persisted?

      t_news = TranslatedNews.last
      assert_equal news.id, t_news.origin_id
      assert_equal "Заголовок", t_news.title
      assert_equal "Содержание", t_news.content
      assert_equal "ru", t_news.locale
    end

    should "Create translation on origin creation" do
      news = News.create :translations_attributes => [{ :title => "Заголовок", :content => "Содержание", :locale => "ru"}]

      assert news.persisted?

      t_news = TranslatedNews.last
      assert_equal news.id, t_news.origin_id.to_i
      assert_equal "Заголовок", t_news.title
      assert_equal "Содержание", t_news.content
      assert_equal "ru", t_news.locale
    end

    should "Create multiple translations" do
      news = News.create :translations_attributes => [{ :title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?

      t_news = TranslatedNews.first
      assert_equal news.id, t_news.origin_id.to_i
      assert_equal "Заголовок", t_news.title
      assert_equal "Содержание", t_news.content
      assert_equal "ru", t_news.locale

      t_news = TranslatedNews.last
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
    end
    
    should "Not been set if unavailable" do
      news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
        {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?
      news.set_current_translation :de

      assert_nil news.title
      assert_nil news.content
    end

    should "Be switched on locale switching" do
      news = News.create :translations_attributes => [{:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

      assert news.persisted?

      t_news = news.translations.create :title => "Заголовок", :content => "Содержание",:locale => "ru"
      assert t_news.persisted?

      ::I18n.locale = ::I18n.default_locale

      assert_equal "Resent News", news.title
      assert_equal "That is where the text goes", news.content

      news.set_current_translation :ru

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
    post = Post.create :translations_attributes => [{:title => "Заголовок",:content => "Содержание", :language => "ru"},
      {:title => "Resent Post", :content => "That is where the text goes", :language => "en"}]
    assert post.persisted?, "Message had errors: #{post.errors.inspect}"

    post = Post.create :translations_attributes => [{:content => "Содержание", :language => "ru"},
      {:title => "Resent Post 2", :content => "That is where the text goes", :language => "en"}]
    
    assert post.new_record?, "Message had errors: #{post.errors.full_messages.inspect}"
    assert_equal ["Translations title can't be blank"], post.errors.full_messages

    post = Post.create :translations_attributes => [{:title => "Заголовок 2", :language => "ru"},
      {:title => "Resent Post 3", :content => "That is where the text goes", :language => "en"}]

    assert post.new_record?, "Message had errors: #{post.errors.full_messages.inspect}"
    assert_equal ["Translations content can't be blank"], post.errors.full_messages

    post = Post.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :language => "ru"},
      {:title => "Resent Post 3", :content => "That is where the text goes", :language => "en"}]

    assert post.new_record?, "Message had errors: #{post.errors.full_messages.inspect}"
    assert_equal ["Translations title has already been taken"], post.errors.full_messages
  end

  def test_origin_is_owerwrittent
    post = Post.create :translations_attributes => [{:title => "Заголовок",:content => "Содержание", :language => "ru"},
      {:title => "Resent Post", :content => "That is where the text goes", :language => "en"}]
    assert post.persisted?, "Message had errors: #{post.errors.inspect}"

    assert_not_equal post.object_id, post.translations.first.post.object_id
  end

  should "Accept aliases for fileds" do
    post = Post.create :translations_attributes => [{:title => "Заголовок",:content => "Содержание", :language => "ru"},
      {:title => "Resent Post", :content => "That is where the text goes", :language => "en"}]
    assert post.persisted?, "Message had errors: #{post.errors.inspect}"

    assert_equal "Resent Post", post.translated_title

    post.set_current_translation :ru

    assert_equal "Заголовок", post.translated_title
  end

  context "Mass assigment" do
    should "Be available to mass assigment by default" do
      tp = TranslatedNews.new( :title => "Resent News", :content => "That is where the text goes", :locale => "en", :origin_id => 1)

      assert_equal "Resent News", tp.title
      assert_equal "That is where the text goes", tp.content
      assert_equal "en", tp.locale
      assert_equal 1, tp.origin_id
    end

    should "Protect internal fields on desire" do
      tm = MessageTranslation.new( :title => "Resent Message", :content => "That is where the text goes", :locale => "en", :message_id => 1)

      assert_equal "Resent Message", tm.title
      assert_equal "That is where the text goes", tm.content
      assert_equal nil, tm.locale
      assert_equal nil, tm.origin_id
    end

    should "Allow multiple assigment rules" do
      tm = MessageTranslation.new( {:title => "Resent Message", :content => "That is where the text goes", :locale => "en", :message_id => 1}, :as => :editor)

      assert_equal "Resent Message", tm.title
      assert_equal "That is where the text goes", tm.content
      assert_equal "en", tm.locale
      assert_equal nil, tm.origin_id
    end
  end
end
