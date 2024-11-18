# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe BlueprinterTypescriptModels::Generator do
  let(:output_dir) { Dir.mktmpdir }

  before do
    puts "\nTest output dir: #{output_dir}"
    BlueprinterTypescriptModels.configure do |config|
      # Use the absolute path from the temp directory
      config.output_dir = output_dir
    end
  end

  after do
    FileUtils.remove_entry output_dir
  end

  describe ".generate_all" do
    it "generates TypeScript interface files" do
      # Generate directly without trying to read from files
      described_class.generate_all

      # Check Post interface
      post_interface = File.read(File.join(output_dir, "IPost.d.ts"))
      expect(post_interface).to include("export interface IPost {")
      expect(post_interface).to include("id: number;")
      expect(post_interface).to include("title: string | null;")
      expect(post_interface).to include("content: string | null;")

      # Check User interface
      user_interface = File.read(File.join(output_dir, "IUser.d.ts"))
      expect(user_interface).to include('import type { IPost } from "./IPost";')
      expect(user_interface).to include("export interface IUser {")
      expect(user_interface).to include("id: number;")
      expect(user_interface).to include("name: string;")
      expect(user_interface).to include("email: string | null;")
      expect(user_interface).to include("posts: IPost[];")

      # Check AdminUser interface
      admin_interface = File.read(File.join(output_dir, "IAdminUser.d.ts"))
      expect(admin_interface).to include('import type { IPost } from "./IPost";')
      expect(admin_interface).to include("export interface IAdminUser {")
      expect(admin_interface).to include("super_admin: boolean | null;")

      # Check CustomUser interface
      custom_interface = File.read(File.join(output_dir, "ICustomUser.d.ts"))
      expect(custom_interface).to include("export interface ICustomUser {")
      expect(custom_interface).to include("name: string;")
      expect(custom_interface).to include("email: string | null;")

      # Check Aliased interface
      aliased_interface = File.read(File.join(output_dir, "IAliased.d.ts"))
      expect(aliased_interface).to include("export interface IAliased {")
      expect(aliased_interface).to include("aliased_name: string;")
    end
  end
end
