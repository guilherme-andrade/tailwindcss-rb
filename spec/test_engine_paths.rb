#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"
require "pathname"

# Simulate Engine.root behavior
module ViewComponentUI
  class Engine
    def self.root
      Pathname.new(File.expand_path("../view-component-ui", __dir__))
    end
  end
end

puts "Testing Engine-style path configuration"
puts "=" * 60
puts "Engine root: #{ViewComponentUI::Engine.root}"

# Test configuration exactly like view-component-ui
Tailwindcss.configure do |config|
  config.mode = :development  # Make sure we're in dev mode
  
  # Paths should be directories, not glob patterns (using your exact config)
  config.content = [
    ViewComponentUI::Engine.root.join('app/components/**/*.rb').to_s,
    ViewComponentUI::Engine.root.join('app/components/**/*.erb').to_s,
    ViewComponentUI::Engine.root.join('app/views/**/*.html.erb').to_s,
    ViewComponentUI::Engine.root.join('spec/components/previews/**/*.rb').to_s,
    ViewComponentUI::Engine.root.join('spec/components/previews/**/*.html.erb').to_s
  ]

  config.compiler.compile_classes_dir = ViewComponentUI::Engine.root.join('tmp/tailwindcss').to_s
  config.compiler.assets_path = ViewComponentUI::Engine.root.join('app/assets/stylesheets').to_s
  config.compiler.output_file_name = 'application'
  config.watch_content = false

  config.breakpoints = %i[xs sm md lg xl 2xl]
  config.pseudo_selectors = %i[hover focus active visited disabled first last
                               first_of_type last_of_type odd even group_hover]
  config.pseudo_elements = %i[before after file first_letter first_line selection backdrop marker]

  config.theme.color_scheme = {
    primary: :blue,
    secondary: :gray,
    tertiary: :green,
    success: :green,
    warning: :yellow,
    danger: :red,
    info: :cyan
  }
end

puts "\nConfiguration:"
puts "  Mode: #{Tailwindcss.resolve_setting(Tailwindcss.config.mode)}"
puts "  Content paths:"
Tailwindcss.resolve_setting(Tailwindcss.config.content).each do |path|
  files = Dir.glob(path).count
  puts "    #{path} (#{files} files)"
end
puts "  Compile dir: #{Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir)}"
puts "  Output path: #{Tailwindcss.output_path}"

# Run extraction
puts "\n\nRunning extraction..."
require "tailwindcss/compiler/runner"
runner = Tailwindcss::Compiler::Runner.new
runner.call

# Check what was extracted
cache_dir = ViewComponentUI::Engine.root.join('tmp/tailwindcss').to_s
if Dir.exist?(cache_dir)
  classes_files = Dir.glob("#{cache_dir}/**/*.classes")
  puts "Created #{classes_files.count} .classes files"
  
  # Check if Tailwind config includes these files
  content_paths = Tailwindcss.resolve_setting(Tailwindcss.config.content).map(&:to_s)
  compile_dir = Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir)
  content_paths << "#{compile_dir}/**/*.classes"
  
  puts "\nContent paths for Tailwind:"
  content_paths.each { |p| puts "  - #{p}" }
  
  # Test compilation
  puts "\n\nCompiling CSS..."
  Tailwindcss.compile_css!
  
  css_file = Tailwindcss.output_path
  if File.exist?(css_file)
    css = File.read(css_file)
    puts "✅ CSS file created: #{css_file}"
    puts "   Size: #{File.size(css_file)} bytes"
    
    # Check for some expected classes
    sample_classes = ["bg-blue-500", "text-white", "hover:bg-blue-600", "rounded", "px-4"]
    found = sample_classes.select { |cls| css.include?(cls.gsub(":", "\\:")) }
    
    if found.any?
      puts "✅ Found utility classes: #{found.join(', ')}"
    else
      puts "⚠️  Expected utility classes not found"
      
      # Check what IS in the CSS
      utilities = css.scan(/\.\w+[-\w]*/).uniq.first(10)
      puts "   Sample classes in CSS: #{utilities.join(', ')}"
    end
  else
    puts "❌ CSS file not created at #{css_file}"
  end
else
  puts "Cache directory doesn't exist!"
end