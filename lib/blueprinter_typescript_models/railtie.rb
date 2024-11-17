# frozen_string_literal: true

module BlueprinterTypescriptModels
  class Railtie < Rails::Railtie
    rake_tasks do
      namespace :typescript do
        desc "Generate TypeScript interfaces from Blueprinter blueprints"
        task generate: :environment do
          puts "Generating TypeScript interfaces from Blueprinter blueprints..."
          Rails.application.eager_load! # Ensure all blueprints are loaded
          BlueprinterTypescriptModels::Generator.generate_all
          puts "TypeScript interfaces generated successfully!"
        end
      end
    end
  end
end
