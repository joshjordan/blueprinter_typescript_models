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
  adapter: "postgresql",
  database: "blueprinter_typescript_models_test",
  host: "localhost",
  username: ENV.fetch("POSTGRES_USER", "postgres"),
  password: ENV.fetch("POSTGRES_PASSWORD", "postgres")
)

# Ensure clean database state for tests
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS users")
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS admin_users")
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS posts")

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

  create_table :admin_users do |t|
    t.boolean :super_admin, default: false
    t.timestamps
  end

  create_table :posts do |t|
    t.string :title
    t.text :content
    t.references :user
    t.timestamps
  end
end
