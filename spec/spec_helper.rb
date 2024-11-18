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
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS posts")

# Create test schema
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :type # For STI
    t.string :name, null: false
    t.string :email
    t.text :bio
    t.jsonb :settings
    t.boolean :admin, null: false, default: false
    t.boolean :super_admin, default: false
    t.datetime :last_login_at
    t.string :tags, array: true
    t.timestamps
  end

  create_table :posts do |t|
    t.string :title
    t.text :content
    t.references :user
    t.timestamps
  end
end

# Define test models
class User < ActiveRecord::Base
end

class AdminUser < User
end

class Post < ActiveRecord::Base
  belongs_to :user
end

# Define test blueprints
class PostBlueprint < Blueprinter::Base
  identifier :id
  field :title
  field :content
end

class UserBlueprint < Blueprinter::Base
  identifier :id
  field :name
  field :email
  field :bio, typescript_type: "string | null"
  field :settings
  field :admin
  field :last_login_at
  field :tags
  field :skipped_field, typescript_type: false
  association :posts, blueprint: PostBlueprint, blueprint_collection: true
end

class AdminUserBlueprint < UserBlueprint
  field :super_admin
end

class CustomUserBlueprint < Blueprinter::Base
  field :name
  field :email

  def self.model_class
    User
  end
end

class VirtualBlueprint < Blueprinter::Base
  field :virtual_field
end

class AliasedBlueprint < Blueprinter::Base
  field :name, name: :aliased_name

  def self.model_class
    User
  end
end
