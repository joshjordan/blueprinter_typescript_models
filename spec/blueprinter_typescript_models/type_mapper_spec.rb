# frozen_string_literal: true

require "spec_helper"

RSpec.describe BlueprinterTypescriptModels::TypeMapper do
  before(:all) do
    # Set up test models
    class User < ActiveRecord::Base; end
    class AdminUser < User; end

    # Blueprint that infers model from name
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

    # Blueprint that inherits model from parent
    class AdminUserBlueprint < UserBlueprint
      field :super_admin
    end

    # Blueprint with explicit model_class
    class CustomUserBlueprint < Blueprinter::Base
      field :name
      field :email

      def self.model_class
        User
      end
    end
  end

  describe ".map_field" do
    context "with explicit typescript_type" do
      it "uses the specified type" do
        field = UserBlueprint.fields.find { |f| f.name == :bio }
        type = described_class.map_field(field, UserBlueprint)
        expect(type).to eq("string | null")
      end
    end

    context "with model inferred from blueprint name" do
      it "maps database types correctly" do
        field = UserBlueprint.fields.find { |f| f.name == :name }
        type = described_class.map_field(field, UserBlueprint)
        expect(type).to eq("string")
      end
    end

    context "with model inherited from parent blueprint" do
      it "maps database types correctly" do
        field = AdminUserBlueprint.fields.find { |f| f.name == :email }
        type = described_class.map_field(field, AdminUserBlueprint)
        expect(type).to eq("string | null")
      end
    end

    context "with explicit model_class" do
      it "maps database types correctly" do
        field = CustomUserBlueprint.fields.find { |f| f.name == :name }
        type = described_class.map_field(field, CustomUserBlueprint)
        expect(type).to eq("string")
      end
    end

    context "with database-backed fields" do
      let(:blueprint_class) { UserBlueprint }

      it "maps nullable string columns correctly" do
        field = blueprint_class.fields.find { |f| f.name == :email }
        type = described_class.map_field(field, blueprint_class)
        expect(type).to eq("string | null")
      end

      it "maps boolean columns correctly" do
        field = blueprint_class.fields.find { |f| f.name == :admin }
        type = described_class.map_field(field, blueprint_class)
        expect(type).to eq("boolean")
      end

      it "maps datetime columns correctly" do
        field = blueprint_class.fields.find { |f| f.name == :last_login_at }
        type = described_class.map_field(field, blueprint_class)
        expect(type).to eq("Date | null")
      end

      it "maps jsonb columns correctly" do
        field = blueprint_class.fields.find { |f| f.name == :settings }
        type = described_class.map_field(field, blueprint_class)
        expect(type).to eq("Record<string, unknown> | null")
      end

      it "maps array columns correctly" do
        field = blueprint_class.fields.find { |f| f.name == :tags }
        type = described_class.map_field(field, blueprint_class)
        expect(type).to eq("string[] | null")
      end
    end

    context "with non-database-backed fields" do
      let(:virtual_blueprint) do
        Class.new(Blueprinter::Base) do
          field :virtual_field
        end
      end

      it "returns unknown for virtual fields" do
        field = virtual_blueprint.fields.find { |f| f.name == :virtual_field }
        type = described_class.map_field(field, virtual_blueprint)
        expect(type).to eq("unknown")
      end
    end
  end
end
