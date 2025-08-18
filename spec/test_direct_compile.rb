#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"
require "fileutils"
require "json"

puts "Testing Direct Tailwind Compilation"
puts "=" * 60

# Setup paths exactly like view-component-ui would
view_component_ui_root = "/Users/guilhermeandrade/Code/view-component-ui"
cache_dir = "#{view_component_ui_root}/tmp/tailwindcss"

# Ensure cache directory exists
FileUtils.mkdir_p(cache_dir)

# Configure Tailwindcss
Tailwindcss.configure do |config|
  config.mode = :development
  
  config.content = [
    "#{view_component_ui_root}/app/components/**/*.rb",
    "#{view_component_ui_root}/app/components/**/*.erb",
    "#{view_component_ui_root}/app/views/**/*.html.erb"
  ]
  
  config.compiler.compile_classes_dir = cache_dir
  config.compiler.assets_path = "#{view_component_ui_root}/app/assets/stylesheets"
  config.compiler.output_file_name = "test_output"
  config.watch_content = false
end

# Run extraction
puts "\n1. Running extraction..."
require "tailwindcss/compiler/runner"
runner = Tailwindcss::Compiler::Runner.new
runner.call

# Check extraction results
classes_files = Dir.glob("#{cache_dir}/**/*.classes")
puts "   Extracted #{classes_files.count} .classes files"

if classes_files.any?
  # Show sample content
  sample_file = classes_files.first
  puts "   Sample: #{sample_file}"
  puts "   Classes: #{File.read(sample_file).split("\n").first(5).join(', ')}"
end

# Build Tailwind config
puts "\n2. Building Tailwind configuration..."
content_paths = Tailwindcss.resolve_setting(Tailwindcss.config.content).map(&:to_s)
content_paths << "#{cache_dir}/**/*.classes"

tailwind_config = {
  content: content_paths
}

puts "   Content paths:"
content_paths.each { |p| puts "     - #{p}" }

# Create temporary config and run Tailwind
puts "\n3. Running Tailwind CLI..."
require 'tempfile'

Tempfile.create(['tailwind', '.config.js']) do |f|
  f.write("module.exports = #{tailwind_config.to_json}")
  f.flush
  
  output_file = "#{view_component_ui_root}/app/assets/stylesheets/test_output.css"
  cmd = ["npx", "tailwindcss", "-o", output_file, "-c", f.path]
  
  puts "   Command: #{cmd.join(' ')}"
  puts "\n   Output:"
  
  # Run with output capture
  output = `#{cmd.join(' ')} 2>&1`
  puts output.lines.map { |l| "     #{l}" }.join
  
  # Check result
  if File.exist?(output_file)
    css = File.read(output_file)
    puts "\n✅ CSS generated: #{output_file}"
    puts "   Size: #{File.size(output_file)} bytes"
    
    # Look for utility classes
    utilities = css.scan(/\.\w+[-\w]*\s*\{/).uniq.count
    puts "   Utility classes found: #{utilities}"
    
    # Clean up test file
    File.delete(output_file)
  else
    puts "\n❌ CSS file not generated"
  end
end