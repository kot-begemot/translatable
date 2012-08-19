# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "translatable"
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["E-Max"]
  s.date = "2012-08-19"
  s.description = "This game was build to make whole proccess of working with translation for DM to be almost invisble. That was THE AIM."
  s.email = "max@studentify.nl"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rvmrc",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/translatable.rb",
    "test/helper.rb",
    "test/news.rb",
    "test/posts.rb",
    "test/support/active_record.rb",
    "test/support/database_cleaner.rb",
    "test/test_translatable.rb",
    "translatable.gemspec"
  ]
  s.homepage = "http://github.com/kot-begemot/translatable"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "An esay way to manage the translations for datamapper"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.6.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<simplecov>, [">= 0.6.0"])
      s.add_development_dependency(%q<rcov>, [">= 1.0.0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 1.6.0"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<simplecov>, [">= 0.6.0"])
      s.add_dependency(%q<rcov>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 1.6.0"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<simplecov>, [">= 0.6.0"])
    s.add_dependency(%q<rcov>, [">= 1.0.0"])
  end
end

