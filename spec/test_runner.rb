#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"

# Set up test environment
test_dir = "./tmp/integration_test"
FileUtils.rm_rf(test_dir)
FileUtils.mkdir_p(test_dir)

test_file = "#{test_dir}/test_component.rb"
File.write(test_file, <<~RUBY)
  class TestComponent
    include Tailwindcss::Helpers
    
    def basic_style
      style(bg: color_token(:blue, 500), text: :white, p: 4, rounded: :lg)
    end
    
    def simple_style
      style(bg: :white, text: :black, border: true)
    end
  end
RUBY

# Configure
Tailwindcss.configure do |config|
  config.mode = :development
  config.compiler.assets_path = "#{test_dir}/assets"
  config.compiler.output_file_name = "test"
  config.compiler.compile_classes_dir = "#{test_dir}/cache"
  config.content = ["#{test_dir}/**/*.rb"]
  config.watch_content = false
end

puts "Running the full compiler flow..."

# Run the runner (which should extract classes and compile)
runner = Tailwindcss::Compiler::Runner.new
runner.call

puts "\n✓ Runner completed"

# Check for .classes files
classes_files = Dir.glob("#{test_dir}/cache/**/*.classes")
puts "\n.classes files created: #{classes_files.size}"
classes_files.each { |f| puts "  - #{f}" }

# Check CSS output
css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css_content = File.read(css_file)
  puts "\n✓ CSS file created: #{css_file}"
  puts "  Size: #{css_content.size} bytes"
  
  # Check for bg-blue in various forms
  if css_content.include?("bg-blue")
    puts "  ✓ Found 'bg-blue' in CSS"
  else
    puts "  ✗ 'bg-blue' not found in CSS"
  end
else
  puts "\n✗ CSS file not created"
end