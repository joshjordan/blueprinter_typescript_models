# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]

namespace :typescript do
  desc "Generate TypeScript interfaces from Blueprinter blueprints"
  task :generate do
    require "blueprinter_typescript_models"
    BlueprinterTypescriptModels::Generator.generate_all
  end
end
