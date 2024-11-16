# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe BlueprinterTypescriptModels::Generator do
  let(:output_dir) { Dir.mktmpdir }
  let(:blueprint_dir) { File.join(output_dir, "blueprints") }

  before do
    FileUtils.mkdir_p(blueprint_dir)
    BlueprinterTypescriptModels.configure do |config|
      config.output_dir = output_dir
    end
  end

  after do
    FileUtils.remove_entry output_dir
  end

  describe ".generate_all" do
    let(:post_blueprint) do
      Class.new(Blueprinter::Base) do
        identifier :id
        field :title
        field :content
      end
    end

    let(:user_with_posts_blueprint) do
      Class.new(Blueprinter::Base) do
        identifier :id
        field :name
        field :email
        association :posts, blueprint: post_blueprint, blueprint_collection: true
      end
    end

    before do
      stub_const("PostBlueprint", post_blueprint)
      stub_const("UserWithPostsBlueprint", user_with_posts_blueprint)
    end

    it "generates TypeScript interface files" do
      described_class.generate_all(blueprint_dir)

      user_interface = File.read(File.join(output_dir, "UserWithPosts.d.ts"))
      post_interface = File.read(File.join(output_dir, "Post.d.ts"))

      # Check Post interface
      expect(post_interface).to include("export interface Post {")
      expect(post_interface).to include("id: number;")
      expect(post_interface).to include("title: string | null;")
      expect(post_interface).to include("content: string | null;")

      # Check User interface
      expect(user_interface).to include('import type { Post } from "./Post";')
      expect(user_interface).to include("export interface UserWithPosts {")
      expect(user_interface).to include("id: number;")
      expect(user_interface).to include("name: string | null;")
      expect(user_interface).to include("email: string | null;")
      expect(user_interface).to include("posts: Post[];")
    end

    context "with custom typescript_type" do
      let(:custom_blueprint) do
        Class.new(Blueprinter::Base) do
          field :status, typescript_type: '"active" | "inactive"'
          field :metadata, typescript_type: "Record<string, unknown>"
        end
      end

      before do
        stub_const("CustomBlueprint", custom_blueprint)
      end

      it "respects custom typescript_type definitions" do
        described_class.generate_all(blueprint_dir)

        interface = File.read(File.join(output_dir, "Custom.d.ts"))
        expect(interface).to include('status: "active" | "inactive";')
        expect(interface).to include("metadata: Record<string, unknown>;")
      end
    end
  end
end
