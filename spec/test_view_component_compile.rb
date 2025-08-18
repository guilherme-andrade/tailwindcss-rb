#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"
require "fileutils"

# Simulate ViewComponentUI configuration
puts "Testing ViewComponentUI-like configuration\n"
puts "=" * 60

# Create a test directory structure similar to view-component-ui
test_root = "./tmp/view_component_test"
FileUtils.rm_rf(test_root)
FileUtils.mkdir_p("#{test_root}/app/components/buttons")
FileUtils.mkdir_p("#{test_root}/tmp/tailwindcss")

# Create a sample component
File.write("#{test_root}/app/components/buttons/button_component.rb", <<~RUBY)
  module ViewComponentUI
    class ButtonComponent
      include Tailwindcss::Helpers
      
      def button_classes
        style(
          bg: color_scheme_token(:primary, 500),
          text: :white,
          px: 4,
          py: 2,
          rounded: :md,
          hover: {
            bg: color_scheme_token(:primary, 600)
          }
        )
      end
    end
  end
RUBY

# Configure like view-component-ui
Tailwindcss.configure do |config|
  # Start in production mode like view-component-ui
  config.mode = :production
  
  config.content = [
    "#{test_root}/app/components/**/*.rb",
    "#{test_root}/app/components/**/*.erb"
  ]
  
  config.compiler.compile_classes_dir = "#{test_root}/tmp/tailwindcss"
  config.compiler.assets_path = "#{test_root}/assets"
  config.compiler.output_file_name = "application"
  config.watch_content = false
  
  config.theme.color_scheme = {
    primary: :blue,
    secondary: :gray,
    success: :green,
    danger: :red
  }
end

puts "\nConfiguration:"
puts "  Mode: #{Tailwindcss.resolve_setting(Tailwindcss.config.mode)}"
puts "  Content paths:"
Tailwindcss.resolve_setting(Tailwindcss.config.content).each do |path|
  puts "    - #{path}"
end
puts "  Compile dir: #{Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir)}"

# Method 1: Force extraction manually
puts "\n\nMethod 1: Using extract_classes!"
puts "-" * 40
Tailwindcss.extract_classes!

# Check what was extracted
cache_dir = "#{test_root}/tmp/tailwindcss"
classes_files = Dir.glob("#{cache_dir}/**/*.classes")
puts "Extracted #{classes_files.count} .classes file(s)"

if classes_files.any?
  classes_files.each do |file|
    puts "\n#{file}:"
    puts "  Classes: #{File.read(file)}"
  end
end

# Now compile CSS
puts "\n\nCompiling CSS..."
Tailwindcss.compile_css!

# Check output
css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css = File.read(css_file)
  puts "CSS file created: #{css_file}"
  puts "CSS file size: #{File.size(css_file)} bytes"
  
  # Check for expected classes
  expected = ["bg-blue-500", "text-white", "px-4", "py-2", "rounded-md"]
  found = expected.select { |cls| css.include?(cls) }
  
  if found.any?
    puts "✅ Found classes: #{found.join(', ')}"
  else
    puts "❌ No expected classes found in CSS"
  end
else
  puts "❌ CSS file not created"
end

# Clean up
FileUtils.rm_rf(test_root)