# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: translatable 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "translatable"
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["E-Max"]
  s.date = "2013-12-18"
  s.description = "This game was build to make whole proccess of working with translation for DM to be almost invisble. That was THE AIM."
  s.email = "max@studentify.nl"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".ruby-gemset",
    ".ruby-version",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/generators/translatable/model_generator.rb",
    "lib/generators/translatable/translation_generator.rb",
    "lib/translatable.rb",
    "lib/translatable/base.rb",
    "lib/translatable/engine.rb",
    "lib/translatable/generator_helper.rb",
    "lib/translatable/orm/active_record.rb",
    "test/cases/active_record_test.rb",
    "test/cases/base_test.rb",
    "test/generators/model_generator_test.rb",
    "test/generators/translation_generator_test.rb",
    "test/support/active_record.rb",
    "test/support/database_cleaner.rb",
    "test/support/models/messages.rb",
    "test/support/models/news.rb",
    "test/support/models/posts.rb",
    "test/test_helper.rb",
    "translatable.gemspec"
  ]
  s.homepage = "http://github.com/kot-begemot/translatable"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.11"
  s.summary = "An esay way to manage the translations for datamapper"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 4.0.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.0"])
    else
      s.add_dependency(%q<activerecord>, [">= 4.0.0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 4.0.0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.0"])
  end
end

