# frozen_string_literal: true

require_relative "blueprinter_typescript_models/version"
require "blueprinter"
require "active_support/core_ext/string/inflections"

module BlueprinterTypescriptModels
  class Error < StandardError; end

  class << self
    def root
      @root ||= Pathname.new(File.expand_path("..", __dir__))
    end

    def configure
      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :output_dir

    def initialize
      @output_dir = "frontend/types"
    end
  end
end

require_relative "blueprinter_typescript_models/type_mapper"
require_relative "blueprinter_typescript_models/generator"
require_relative "blueprinter_typescript_models/railtie" if defined?(Rails)
