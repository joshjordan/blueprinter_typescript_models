# frozen_string_literal: true

require "blueprinter_typescript_models"
require "active_record"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Setup test database connection
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Create test schema
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name, null: false
    t.string :email
    t.text :bio
    t.jsonb :settings
    t.boolean :admin, default: false
    t.datetime :last_login_at
    t.string :tags, array: true
    t.timestamps
  end
end

# Define test models
class User < ActiveRecord::Base
end

# Define test blueprints
class UserBlueprint < Blueprinter::Base
  identifier :id
  field :name
  field :email
  field :bio, typescript_type: "string | null"
  field :settings
  field :admin
  field :last_login_at
  field :tags
end
