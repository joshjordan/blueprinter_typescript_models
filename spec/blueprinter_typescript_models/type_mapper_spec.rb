# frozen_string_literal: true

require "spec_helper"

RSpec.describe BlueprinterTypescriptModels::TypeMapper do
  describe ".map_field" do
    context "with explicit typescript_type" do
      it "uses the specified type" do
        type = described_class.map_field(:bio, UserBlueprint)
        expect(type).to eq("string | null")
      end
    end

    context "with model inferred from blueprint name" do
      it "maps database types correctly" do
        type = described_class.map_field(:name, UserBlueprint)
        expect(type).to eq("string")
      end
    end

    context "with model inherited from parent blueprint" do
      it "maps database types correctly" do
        type = described_class.map_field(:email, AdminUserBlueprint)
        expect(type).to eq("string | null")
      end
    end

    context "with explicit model_class" do
      it "maps database types correctly" do
        type = described_class.map_field(:name, CustomUserBlueprint)
        expect(type).to eq("string")
      end
    end

    context "with database-backed fields" do
      let(:blueprint_class) { UserBlueprint }

      it "maps nullable string columns correctly" do
        type = described_class.map_field(:email, blueprint_class)
        expect(type).to eq("string | null")
      end

      it "maps boolean columns correctly" do
        type = described_class.map_field(:admin, blueprint_class)
        expect(type).to eq("boolean")
      end

      it "maps datetime columns correctly" do
        type = described_class.map_field(:last_login_at, blueprint_class)
        expect(type).to eq("Date | null")
      end

      it "maps jsonb columns correctly" do
        type = described_class.map_field(:settings, blueprint_class)
        expect(type).to eq("Record<string, unknown> | null")
      end

      it "maps array columns correctly" do
        type = described_class.map_field(:tags, blueprint_class)
        expect(type).to eq("string[] | null")
      end
    end

    context "with non-database-backed fields" do
      it "returns unknown for virtual fields" do
        type = described_class.map_field(:virtual_field, VirtualBlueprint)
        expect(type).to eq("unknown")
      end
    end
  end
end
