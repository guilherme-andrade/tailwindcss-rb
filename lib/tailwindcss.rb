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
    setting :assets_path, default: proc { "./public/assets" }
    setting :output_file_name, default: proc { "styles" }
    setting :compile_classes_dir, default: proc { "./tmp/tailwindcss" }
  end
  setting :content, default: proc { [] }
  setting :prefix, default: ""

  setting :tailwind_css_file_path, default: proc { Tailwindcss.output_path }
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
    @theme ||= OpenStruct.new(config.theme.to_h.transform_values { |v| resolve_setting(v) })
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

  def resolve_setting(setting)
    setting.respond_to?(:call) ? setting.call : setting
  end
  
  def production_mode?
    resolve_setting(config.mode) == :production
  end

  def development_mode?
    !production_mode?
  end

  def compile_css!
    log_info "Recompiling Tailwindcss..."
    system "npx tailwindcss -o #{output_path} -m"
    Compiler::Channel.broadcast_css_changed if defined?(ActionCable)
  end

  def output_path
    assets_path = resolve_setting(config.compiler.assets_path)
    output_file_name = resolve_setting(config.compiler.output_file_name)
    File.join(assets_path, "#{output_file_name}.css")
  end

  def tailwind_css_file_path
    @tailwind_css_file_path ||= resolve_setting(config.tailwind_css_file_path)
  end

  def logger
    @logger ||= resolve_setting(config.logger)
  rescue
    nil
  end
  
  def log_debug(message)
    logger&.debug(message)
  end
  
  def log_info(message)
    logger&.info(message)
  end
  
  def log_warn(message)
    logger&.warn(message)
  end
  
  def log_error(message)
    logger&.error(message)
  end
end
