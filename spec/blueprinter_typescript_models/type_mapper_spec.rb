# frozen_string_literal: true

require "spec_helper"

RSpec.describe BlueprinterTypescriptModels::TypeMapper do
  let(:user_blueprint) { UserBlueprint }

  describe ".map_field" do
    context "with explicit typescript_type" do
      it "uses the specified type" do
        field = user_blueprint.fields[:bio]
        type = described_class.map_field(field, user_blueprint)
        expect(type).to eq("string | null")
      end
    end

    context "with database-backed fields" do
      it "maps string columns correctly" do
        field = user_blueprint.fields[:name]
        type = described_class.map_field(field, user_blueprint)
        expect(type).to eq("string")
      end

      it "maps nullable string columns correctly" do
        field = user_blueprint.fields[:email]
        type = described_class.map_field(field, user_blueprint)
        expect(type).to eq("string | null")
      end

      it "maps boolean columns correctly" do
        field = user_blueprint.fields[:admin]
        type = described_class.map_field(field, user_blueprint)
        expect(type).to eq("boolean")
      end

      it "maps datetime columns correctly" do
        field = user_blueprint.fields[:last_login_at]
        type = described_class.map_field(field, user_blueprint)
        expect(type).to eq("Date | null")
      end

      it "maps jsonb columns correctly" do
        field = user_blueprint.fields[:settings]
        type = described_class.map_field(field, user_blueprint)
        expect(type).to eq("Record<string, unknown> | null")
      end

      it "maps array columns correctly" do
        field = user_blueprint.fields[:tags]
        type = described_class.map_field(field, user_blueprint)
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
        field = virtual_blueprint.fields[:virtual_field]
        type = described_class.map_field(field, virtual_blueprint)
        expect(type).to eq("unknown")
      end
    end
  end
end
