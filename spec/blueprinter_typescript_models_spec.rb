# frozen_string_literal: true

require "spec_helper"

RSpec.describe BlueprinterTypescriptModels do
  it "has a version number" do
    expect(BlueprinterTypescriptModels::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "allows setting the output directory" do
      described_class.configure do |config|
        config.output_dir = "custom/types"
      end

      expect(described_class.configuration.output_dir).to eq("custom/types")
    end

    after do
      # Reset to default configuration
      described_class.configure do |config|
        config.output_dir = "frontend/types"
      end
    end
  end
end
