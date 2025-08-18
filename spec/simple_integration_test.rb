#!/usr/bin/env ruby
# Simple integration test

require "bundler/setup"
require "tailwindcss"
require "fileutils"

# Create a test file with simple Tailwind classes
test_dir = "./tmp/integration_test"
FileUtils.mkdir_p(test_dir)

test_file = "#{test_dir}/test_component.rb"
File.write(test_file, <<~RUBY)
  class TestComponent
    include Tailwindcss::Helpers
    
    def basic_style
      style(bg: :blue, text: :white, p: 4, rounded: :lg)
    end
    
    def color_style
      style(bg: color_token(:red, 500), text: color_token(:gray, 100))
    end
    
    def dark_style
      dark(bg: :gray, text: :white)
    end
    
    def responsive_style
      at(:md, display: :flex, gap: 4)
    end
  end
RUBY

# Configure Tailwindcss
Tailwindcss.configure do |config|
  config.mode = :development
  config.compiler.assets_path = "#{test_dir}/assets"
  config.compiler.output_file_name = "test"
  config.compiler.compile_classes_dir = "#{test_dir}/cache"
  config.content = ["#{test_dir}/**/*.rb"]
end

puts "Testing Tailwindcss Compiler Integration\n"
puts "=" * 40

# Test extraction
extractor = Tailwindcss::Compiler::FileClassesExtractor.new
classes = extractor.call(file_path: test_file)

puts "\n✓ Extracted #{classes.size} classes:"
classes.each { |c| puts "  - #{c}" }

# Test compilation
runner = Tailwindcss::Compiler::Runner.new
runner.call

output_file = Tailwindcss.output_path
if File.exist?(output_file)
  css_content = File.read(output_file)
  puts "\n✓ CSS file generated at: #{output_file}"
  puts "  File size: #{css_content.size} bytes"
  
  # Check for some expected classes
  expected = [".bg-blue", ".text-white", ".p-4", ".rounded-lg"]
  found = expected.select { |c| css_content.include?(c) }
  puts "\n✓ Found #{found.size}/#{expected.size} expected classes in CSS:"
  found.each { |c| puts "  - #{c}" }
else
  puts "\n✗ CSS file not generated!"
end

# Clean up
# FileUtils.rm_rf(test_dir)  # Keep for inspection

puts "\nTest completed!"
puts "\nFiles kept in #{test_dir} for inspection"