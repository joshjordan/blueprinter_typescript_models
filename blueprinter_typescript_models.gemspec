# frozen_string_literal: true

require_relative "lib/blueprinter_typescript_models/version"

ruby_version = File.read(File.join(__dir__, '.ruby-version')).strip

Gem::Specification.new do |spec|
  spec.name = "blueprinter_typescript_models"
  spec.version = BlueprinterTypescriptModels::VERSION
  spec.authors = ["Josh Jordan"]
  spec.email = ["josh.jordan@gmail.com"]

  spec.summary = "Generate TypeScript types from Ruby Blueprinter blueprints"
  spec.description = "Automatically generate TypeScript type definitions from Blueprinter serializers, using Blueprinter's declarative DSL for type annotations. Supports custom typescript_type metadata for fields and falls back to database schema types."
  spec.homepage = "https://github.com/joshjordan/blueprinter_typescript_models"
  spec.license = "MIT"
  spec.required_ruby_version = ">= #{ruby_version}"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "blueprinter", "~> 0.30.0"
  spec.add_dependency "activesupport", ">= 5.0"
  spec.add_dependency "rake", ">= 12.0"

  spec.add_development_dependency "rails", ">= 6.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.22"
end
