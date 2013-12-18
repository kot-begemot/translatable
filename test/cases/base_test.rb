# encoding: utf-8
require 'test_helper'

class Paper
end

class TranslatedPaper
end

class DefiningBaseTest < Test::Unit::TestCase
  setup do
    @base = Translatable::Base.new(Paper)
  end

  #context "Defining" do
    test "should Simple field" do
      @base.field :title

      assert_equal [[:title, {}]], @base.fields
    end

    test "should Several fields" do
      @base.field :title
      @base.field :content, :presence => true

      assert_equal [[:title, {}], [:content, {:presence => true}]], @base.fields
    end

    test "should Have mapping" do
      @base.field :title
      @base.field :content, :as => :paper_content, :presence => true

      assert_equal({:title => :title, :content => :paper_content, :locale => :locale}, @base.mapping)
    end

    test "should Have mapping (with locale)" do
      @base.field :title
      @base.field :content, :as => :paper_content, :presence => true
      @base.locale_key :locale, :as => :language

      assert_equal({:title => :title, :content => :paper_content, :locale => :language}, @base.mapping)
    end

    test "should Translation model (as class)" do
      @base.class_name TranslatedPaper

      assert_equal TranslatedPaper, @base.translation_model
    end

    test "should Translation model (as string)" do
      @base.class_name "TranslatedPaper"

      assert_equal TranslatedPaper, @base.translation_model
    end

    test "should Translation model (as symbol)" do
      @base.class_name :TranslatedPaper

      assert_equal TranslatedPaper, @base.translation_model
    end

    test "should Origin key" do
      @base.foreign_key :article_id

      assert_equal :article_id, @base.origin_key
    end

    test "should Reflection name" do
      @base.reflection_name :article

      assert_equal :article, @base.origin_reflection_name
    end

    test "should Locale key" do
      @base.locale_key :language

      assert_equal :language, @base.locale_column
    end
  #end
end

class DefaultingBaseTest < Test::Unit::TestCase
  setup do
    @base = Translatable::Base.new(Paper)
  end

  #context "Defaulting" do
    test "should Translation model" do
      assert_equal TranslatedPaper, @base.translation_model
    end

    test "should Origin key" do
      assert_equal :origin_id, @base.origin_key
    end

    test "should Reflection name" do
      assert_equal :origin, @base.origin_reflection_name
    end

    test "should Locale key" do
      assert_equal :locale, @base.locale_column
    end
  #end
end