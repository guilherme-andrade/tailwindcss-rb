#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"
require "fileutils"

# Create test environment
test_dir = "./tmp/extraction_debug"
FileUtils.rm_rf(test_dir)
FileUtils.mkdir_p(test_dir)

# Create a test component
test_file = "#{test_dir}/test.rb"
File.write(test_file, <<~RUBY)
  class TestComponent
    include Tailwindcss::Helpers
    
    def styles
      style(bg: color_token(:blue, 500), p: 4, text: :white)
    end
  end
RUBY

puts "Testing Class Extraction\n"
puts "=" * 40

# Configure
Tailwindcss.configure do |config|
  config.mode = :development
  config.compiler.assets_path = "#{test_dir}/assets"
  config.compiler.output_file_name = "output"
  config.compiler.compile_classes_dir = "#{test_dir}/cache"
  config.content = ["#{test_dir}/**/*.rb"]
  config.watch_content = false
end

# Test the file classes extractor directly
require "tailwindcss/compiler/file_classes_extractor"

extractor = Tailwindcss::Compiler::FileClassesExtractor.new
puts "\nExtracting classes from: #{test_file}"

begin
  classes = extractor.call(file_path: test_file)
  puts "Extracted classes: #{classes.inspect}"
rescue => e
  puts "Error extracting classes: #{e.message}"
  puts e.backtrace.first(5)
end

# Now run the full runner
puts "\nRunning full compiler..."
runner = Tailwindcss::Compiler::Runner.new
runner.call

# Check cache directory
cache_dir = "#{test_dir}/cache"
puts "\nCache directory contents:"
if Dir.exist?(cache_dir)
  Dir.glob("#{cache_dir}/**/*").each do |file|
    puts "  #{file}"
    if file.end_with?(".classes")
      puts "    Contents: #{File.read(file).split("\n").inspect}"
    end
  end
else
  puts "  Cache directory doesn't exist!"
end

# Clean up
FileUtils.rm_rf(test_dir)