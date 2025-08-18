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
  
  # Tailwind CSS configuration options
  setting :darkMode, default: "class" # 'media' | 'class' | false
  setting :important, default: false # boolean | string (selector)
  setting :separator, default: ":" # string
  setting :safelist, default: proc { [] } # array of classes to always include
  setting :blocklist, default: proc { [] } # array of classes to exclude
  setting :presets, default: proc { [] } # array of preset configs
  setting :plugins, default: proc { [] } # array of plugin names/paths
  setting :corePlugins, default: proc { {} } # hash to enable/disable core plugins

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
    
    # Build the tailwindcss command with configuration
    cmd = ["npx", "tailwindcss"]
    
    # Output file
    cmd << "-o" << output_path
    
    # Minify in production
    cmd << "-m" if production_mode?
    
    # Content paths - include both configured paths and the .classes files
    content_paths = resolve_setting(config.content).map(&:to_s)
    compile_dir = resolve_setting(config.compiler.compile_classes_dir)
    content_paths << "#{compile_dir}/**/*.classes"
    
    # Build full Tailwind configuration
    tailwind_config = build_tailwind_config(content_paths)
    
    # Write temporary config
    require 'tempfile'
    require 'json'
    
    Tempfile.create(['tailwind', '.config.js']) do |f|
      f.write("module.exports = #{tailwind_config.to_json}")
      f.flush
      
      cmd << "-c" << f.path
      
      # Run the command
      system(*cmd)
    end
    
    Compiler::Channel.broadcast_css_changed if defined?(ActionCable)
  end
  
  def build_tailwind_config(content_paths)
    config_hash = {
      content: content_paths
    }
    
    # Add dark mode configuration
    dark_mode = resolve_setting(config.darkMode)
    config_hash[:darkMode] = dark_mode unless dark_mode == "class" # class is default
    
    # Add important configuration
    important = resolve_setting(config.important)
    config_hash[:important] = important if important
    
    # Add separator if not default
    separator = resolve_setting(config.separator)
    config_hash[:separator] = separator unless separator == ":"
    
    # Add safelist
    safelist = resolve_setting(config.safelist)
    config_hash[:safelist] = safelist if safelist.present?
    
    # Add blocklist
    blocklist = resolve_setting(config.blocklist)
    config_hash[:blocklist] = blocklist if blocklist.present?
    
    # Add prefix if configured
    prefix_value = resolve_setting(config.prefix)
    config_hash[:prefix] = prefix_value if prefix_value.present?
    
    # Add theme configuration
    theme_config = {}
    
    # Add breakpoints if customized
    breakpoints = resolve_setting(config.breakpoints)
    if breakpoints != BREAKPOINTS
      theme_config[:screens] = breakpoints
    end
    
    # Add any theme overrides
    theme_overrides = resolve_setting(config.tailwind_config_overrides)
    if theme_overrides.present?
      theme_config[:extend] = theme_overrides
    end
    
    config_hash[:theme] = theme_config if theme_config.present?
    
    # Add plugins
    plugins = resolve_setting(config.plugins)
    if plugins.present?
      # Plugins need to be required, not just listed as strings
      # For now, we'll pass them as strings and assume they're installed
      config_hash[:plugins] = plugins
    end
    
    # Add core plugins configuration
    core_plugins = resolve_setting(config.corePlugins)
    config_hash[:corePlugins] = core_plugins if core_plugins.present?
    
    # Add presets
    presets = resolve_setting(config.presets)
    config_hash[:presets] = presets if presets.present?
    
    config_hash
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
