#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"

# Test with development mode
Tailwindcss.configure do |config|
  config.mode = :development  # Ensure we're in development mode
  
  config.content = [
    "../view-component-ui/app/components/**/*.rb",
    "../view-component-ui/app/components/**/*.erb"
  ].map { |p| File.expand_path(p) }
  
  config.compiler.compile_classes_dir = "./tmp/debug_extraction"
  config.compiler.assets_path = "./tmp/debug_extraction"
  config.compiler.output_file_name = "output"
  config.watch_content = false
  
  config.theme.color_scheme = {
    primary: :blue,
    secondary: :gray,
    success: :green,
    danger: :red
  }
end

puts "Debug Extraction Test"
puts "=" * 60
puts "Mode: #{Tailwindcss.resolve_setting(Tailwindcss.config.mode)}"
puts "Should extract: #{Tailwindcss.development_mode?}"

# Check what init! does
puts "\nCalling init! (should trigger extraction in dev mode)..."
Tailwindcss.init!

# Check cache directory
cache_dir = "./tmp/debug_extraction"
if Dir.exist?(cache_dir)
  classes_files = Dir.glob("#{cache_dir}/**/*.classes")
  puts "\nFound #{classes_files.count} .classes files after init!"
  
  if classes_files.empty?
    puts "No classes files created - extraction may have failed"
  else
    puts "\nSample classes files:"
    classes_files.first(3).each do |file|
      content = File.read(file)
      puts "  #{file}: #{content.split("\n").first(3).join(', ')}..."
    end
  end
else
  puts "Cache directory doesn't exist!"
end

# Now test compile_css!
puts "\n\nCalling compile_css!..."
Tailwindcss.compile_css!

# Check CSS output
css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css = File.read(css_file)
  puts "CSS file created: #{css_file}"
  puts "CSS file size: #{File.size(css_file)} bytes"
  
  # Look for any utility classes
  utilities = css.scan(/\.\w+[-\w]*\s*\{/).first(10)
  if utilities.any?
    puts "Sample utility classes found:"
    utilities.each { |u| puts "  #{u}" }
  else
    puts "No utility classes found in CSS"
  end
end