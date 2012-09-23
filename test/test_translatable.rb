# encoding: utf-8
require 'helper'
require 'news'
require 'posts'
require 'messages'

class TestDmTranslatable < Test::Unit::TestCase

  def setup
    before_setup
  end

  def teardown
    after_teardown
  end

  def test_translatable_hash_is_defined
    th = News.instance_variable_get :@translatable

    assert_kind_of Hash, th
    assert th.has_key?(:properties)
  end

  def test_translatable_hash_has_default_model
    assert_equal ::TranslatableNews, News.send(:translatable_model_prepared, 'TranslatableNews')
  end

  def test_translatable_assepts_constant_as_model
    assert_equal ::TranslatableNews, News.send(:translatable_model_prepared, ::TranslatableNews)
  end

  def test_translatable_assepts_sting_as_model
    assert_equal ::TranslatableNews, News.send(:translatable_model_prepared, "TranslatableNews")
  end

  def test_translatable_assepts_symbol_as_model
    assert_equal ::TranslatableNews, News.send(:translatable_model_prepared, :TranslatableNews)
  end

  def test_instance_respond_to_translatable_methods
    news = News.new

    assert news.respond_to?(:title), "title methods is missing for News instance"
    assert news.respond_to?(:content), "content methods is missing for News instance"
  end

  def test_translated_instance_has_translatable_methods
    news = TranslatableNews.new

    assert news.respond_to?(:title), "Title method is missing for TranslatableNews instance"
    assert news.respond_to?(:content), "Content method is missing for TranslatableNews instance"
  end

  def test_translated_instance_has_relation_to_origin
    news = TranslatableNews.new

    assert news.respond_to?(:locale), "Locale method is missing for TranslatableNews instance"
    assert news.respond_to?(:origin_id), "Origin methods is missing for TranslatableNews instance"
    assert news.respond_to?(:origin), "Origin methods is missing for TranslatableNews instance"
  end

  def test_create_without_translation
    news = News.create

    assert news.persisted?
    assert_nil TranslatableNews.last
  end

  def test_create_translated_with_translation
    news = News.create
    t_news = TranslatableNews.create :title => "Заголовок", :content => "Содержание", :locale => "ru", :origin_id => news.id

    assert t_news.persisted?

    t_news = TranslatableNews.last
    assert_equal news.id, t_news.origin_id
    assert_equal "Заголовок", t_news.title
    assert_equal "Содержание", t_news.content
    assert_equal "ru", t_news.locale
  end

  def test_create_with_translation
    news = News.create :translations_attributes => [{ :title => "Заголовок", :content => "Содержание", :locale => "ru"}]

    assert news.persisted?

    t_news = TranslatableNews.last
    assert_equal news.id, t_news.origin_id.to_i
    assert_equal "Заголовок", t_news.title
    assert_equal "Содержание", t_news.content
    assert_equal "ru", t_news.locale
  end

  def test_no_other_translations
    news = News.create :translations_attributes => [{ :title => "Заголовок", :content => "Содержание", :locale => "ru"}]

    assert news.persisted?

    t_news = TranslatableNews.last
    assert_equal [t_news], news.other_translations
    ::I18n.locale = :ru
     assert_equal [], news.other_translations
    ::I18n.locale = ::I18n.default_locale
  end

  def test_create_with_translation_with_multiple_locales
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

  def test_access_of_default_translation
    news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
      {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

    assert news.persisted?

    assert_equal "Resent News", news.title
    assert_equal "That is where the text goes", news.content
  end

  def test_access_of_different_translation
    news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
      {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

    assert news.persisted?

    ::I18n.locale = :ru
    assert_equal "Заголовок", news.title
    assert_equal "Содержание", news.content
    ::I18n.locale = ::I18n.default_locale
  end

  def test_adding_the_translation
    news = News.create :translations_attributes => [{:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

    assert news.persisted?

    t_news = news.translations.create :title => "Заголовок", :content => "Содержание",:locale => "ru"

    assert t_news.persisted?
    assert t_news.persisted?
  end

  def test_getting_different_translations
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
    ::I18n.locale = ::I18n.default_locale
  end

  def test_access_unexisting_translation
    news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
      {:title => "Resent News", :content => "That is where the text goes", :locale => "en"}]

    assert news.persisted?

    ::I18n.locale = :de
    assert_nil news.title
    assert_nil news.content
    ::I18n.locale = ::I18n.default_locale
  end

  def test_errors_on_translation_creation
    news = News.create :translations_attributes => [{:title => "Заголовок", :content => "Содержание", :locale => "ru"},
      {:title => "Resent News", :content => "That is where the text goes", :locale => ""}]

    assert news.new_record?

    assert_equal ["Translations locale can't be blank"], news.errors.full_messages

    news.translations.each do |t|
      assert t.new_record?
    end
  end

  def test_validations_are_defined
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

    assert_equal post, post.translations.first.post
  end

  def test_attr_as
    post = Post.create :translations_attributes => [{:title => "Заголовок",:content => "Содержание", :locale => "ru"},
      {:title => "Resent Post", :content => "That is where the text goes", :locale => "en"}]
    assert post.persisted?, "Message had errors: #{post.errors.inspect}"

    assert_equal "Resent Post", post.translated_title

    ::I18n.locale = :ru
    assert_equal "Заголовок", post.translated_title
    ::I18n.locale = ::I18n.default_locale
  end

  def test_protected_mass_assigment
    tm = TranslatedMessage.new( :title => "Resent Post", :content => "That is where the text goes", :locale => "en", :message_id => 1)

    assert_equal "Resent Post", tm.title
    assert_equal "That is where the text goes", tm.content
    assert_equal nil, tm.locale
    assert_equal nil, tm.message_id
  end

  def test_protected_editor_mass_assigment
    tm = TranslatedMessage.new( {:title => "Resent Post", :content => "That is where the text goes", :locale => "en", :message_id => 1}, :as => :editor)

    assert_equal "Resent Post", tm.title
    assert_equal "That is where the text goes", tm.content
    assert_equal "en", tm.locale
    assert_equal nil, tm.message_id
  end

  def test_accessible_mass_assigment
    tp = TranslatableNews.new( :title => "Resent News", :content => "That is where the text goes", :locale => "en", :origin_id => 1)

    assert_equal "Resent News", tp.title
    assert_equal "That is where the text goes", tp.content
    assert_equal "en", tp.locale
    assert_equal 1, tp.origin_id
  end
end
