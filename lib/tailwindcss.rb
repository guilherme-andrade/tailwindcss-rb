# frozen_string_literal: true

require "dry/configurable"
require "deep_merge/rails_compat"

require "tailwindcss/version"
require "tailwindcss/constants"
require "tailwindcss/compiler/runner"

module Tailwindcss
  extend Dry::Configurable
  include Constants

  module_function

  setting :mode, default: proc {
    if ENV["RAILS_ENV"] == "production" || ENV["RACK_ENV"] == "production"
      :production
    else
      :development
    end
  }

  setting :package_json_path, default: proc { "./package.json" }
  setting :config_file_path, default: proc { "./tailwind.config.js" }
  setting :compiler do
    setting :output_path, default: proc { "./public/assets/styles.css" }
    setting :compile_classes_dir, default: proc { "./tmp/tailwindcss" }
  end
  setting :content, default: proc { [] }
  setting :prefix, default: ""

  setting :tailwind_css_file_path, default: proc { Tailwindcss.config.compiler.output_path.call }
  setting :tailwind_config_overrides, default: proc { {} }
  setting :watch_content, default: false

  setting :breakpoints, default: BREAKPOINTS
  setting :pseudo_selectors, default: PSEUDO_SELECTORS
  setting :pseudo_elements, default: PSEUDO_ELEMENTS

  setting :theme do
    THEME.each do |directive, config|
      setting directive, default: proc { config }
    end
    setting :color_scheme, default: proc { COLOR_SCHEME }
  end

  setting :logger, default: proc { Logger.new($stdout) }

  module ExtendTheme
    def extend_theme(**overrides)
      self.theme = theme.deeper_merge(overrides)
    end
  end

  config.extend ExtendTheme

  def theme
    @theme ||= OpenStruct.new(config.theme.to_h.transform_values { _1.respond_to?(:call) ? _1.call : _1 })
  end

  def configure(&blk)
    super
    @theme = nil  # Clear cached theme
    init!
  end

  def init!
    require "tailwindcss/style"
    @theme = nil  # Clear cached theme

    # Skip compilation in production mode
    return if production_mode?

    Compiler::Runner.new.call
  end

  def production_mode?
    mode = config.mode
    mode = mode.call if mode.respond_to?(:call)
    mode == :production
  end

  def development_mode?
    !production_mode?
  end

  def compile_css!
    Tailwindcss.config.logger.call.info "Recompiling Tailwindcss..."
    system "npx tailwindcss -o #{output_path} -m"
    Channel.broadcast_css_changed if defined?(ActionCable)
  end

  def output_path
    path = Tailwindcss.config.compiler.output_path
    path.respond_to?(:call) ? path.call : path
  end

  def tailwind_css_file_path
    path = Tailwindcss.config.tailwind_css_file_path
    @tailwind_css_file_path ||= path.respond_to?(:call) ? path.call : path
  end

  def logger
    @logger ||= config.logger.call
  end
end
