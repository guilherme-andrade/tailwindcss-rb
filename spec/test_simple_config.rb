#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"
require "fileutils"
require "json"

# Create test environment
test_dir = "./tmp/simple_config_test"
FileUtils.rm_rf(test_dir)
FileUtils.mkdir_p(test_dir)

# Create a test component with classes
test_file = "#{test_dir}/test.rb"
File.write(test_file, <<~RUBY)
  class TestComponent
    include Tailwindcss::Helpers
    
    def styles
      style(bg: color_token(:blue, 500), p: 4, text: :white)
    end
  end
RUBY

puts "Testing Configuration Passing to Tailwind CLI\n"
puts "=" * 40

# Configure with prefix
Tailwindcss.configure do |config|
  config.mode = :development
  config.compiler.assets_path = "#{test_dir}/assets"
  config.compiler.output_file_name = "output"
  config.compiler.compile_classes_dir = "#{test_dir}/cache"
  config.content = ["#{test_dir}/**/*.rb"]
  config.prefix = "tw-"
  config.important = true
  config.watch_content = false
end

# Run the compiler to extract classes
runner = Tailwindcss::Compiler::Runner.new
runner.call

# Check what classes were extracted
cache_file = "#{test_dir}/cache/.classes"
if File.exist?(cache_file)
  classes = File.read(cache_file).split("\n")
  puts "Extracted classes: #{classes.inspect}"
else
  puts "Warning: No .classes file found"
end

# Now trigger the CSS compilation with dry-run to see the command
require 'tempfile'
require 'json'

# Build configuration
content_paths = Tailwindcss.resolve_setting(Tailwindcss.config.content).map(&:to_s)
compile_dir = Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir)
content_paths << "#{compile_dir}/**/*.classes"

tailwind_config = Tailwindcss.build_tailwind_config(content_paths)

puts "\nGenerated Tailwind Config:"
puts JSON.pretty_generate(tailwind_config)

# Create temp config file and build command
Tempfile.create(['tailwind', '.config.js']) do |f|
  f.write("module.exports = #{tailwind_config.to_json}")
  f.flush
  
  cmd = ["npx", "tailwindcss"]
  cmd << "-o" << Tailwindcss.output_path
  cmd << "-c" << f.path
  
  puts "\nCommand that would be executed:"
  puts cmd.join(" ")
  
  puts "\nExecuting command..."
  system(*cmd)
end

# Check the output
css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css_content = File.read(css_file)
  
  puts "\nChecking generated CSS..."
  
  # Check for prefix
  if css_content.include?(".tw-bg-blue-500")
    puts "✅ Prefix 'tw-' applied"
  else
    puts "❌ Prefix not found"
    if css_content.include?(".bg-blue-500")
      puts "   Found unprefixed class .bg-blue-500"
    end
  end
  
  # Check for important
  if css_content.include?("!important")
    puts "✅ Important flag applied"
  else
    puts "❌ Important flag not applied"
  end
  
  puts "\nFirst 500 chars of CSS:"
  puts css_content[0..500]
end

# Clean up
FileUtils.rm_rf(test_dir)