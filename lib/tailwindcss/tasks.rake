# frozen_string_literal: true

# This file provides Rake tasks that work with or without Rails

namespace :tailwindcss do
  # Helper to load environment if available
  def load_environment
    if Rake::Task.task_defined?("environment")
      Rake::Task["environment"].invoke
    elsif defined?(Rails)
      Rails.application.initialize! if Rails.application
    elsif File.exist?("config/environment.rb")
      require "./config/environment"
    elsif File.exist?("lib/view_component_ui.rb")
      # For gems/engines, load the main file
      require "view_component_ui"
    end
  end
  
  desc "Extract Tailwind classes from Ruby/ERB files"
  task :extract do
    load_environment
    require "tailwindcss"
    require "tailwindcss/compiler/runner"
    
    puts "Extracting Tailwind classes..."
    puts "Mode: #{Tailwindcss.resolve_setting(Tailwindcss.config.mode)}"
    
    # Force extraction even in production mode
    runner = Tailwindcss::Compiler::Runner.new
    runner.call
    
    # Show results
    compile_dir = Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir)
    classes_files = Dir.glob("#{compile_dir}/**/*.classes")
    puts "Extracted #{classes_files.count} .classes files to #{compile_dir}"
    
    puts "Extraction complete!"
  end
  
  desc "Compile Tailwind CSS (runs extraction first)"
  task :compile do
    load_environment
    require "tailwindcss"
    require "tailwindcss/compiler/runner"
    
    puts "Compiling Tailwind CSS..."
    puts "Mode: #{Tailwindcss.resolve_setting(Tailwindcss.config.mode)}"
    
    # Force extraction first
    puts "\nStep 1: Extracting classes..."
    runner = Tailwindcss::Compiler::Runner.new
    runner.call
    
    # Show extraction results
    compile_dir = Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir)
    classes_files = Dir.glob("#{compile_dir}/**/*.classes")
    puts "  → Extracted #{classes_files.count} .classes files"
    
    # Then compile
    puts "\nStep 2: Compiling CSS..."
    Tailwindcss.compile_css!
    
    # Show output location
    output_path = Tailwindcss.output_path
    if File.exist?(output_path)
      size = File.size(output_path)
      puts "  → CSS compiled to #{output_path} (#{size} bytes)"
    end
    
    puts "\n✅ Compilation complete!"
  end
  
  desc "Watch for changes and recompile"
  task :watch do
    load_environment
    require "tailwindcss"
    require "tailwindcss/compiler/runner"
    
    puts "Watching for changes..."
    puts "Mode: #{Tailwindcss.resolve_setting(Tailwindcss.config.mode)}"
    
    # Force watch mode
    runner = Tailwindcss::Compiler::Runner.new(watch: true)
    runner.call
    
    # Keep the process running
    sleep
  end
end

# Also provide a top-level task for convenience
desc "Compile Tailwind CSS"
task :tailwindcss => "tailwindcss:compile"