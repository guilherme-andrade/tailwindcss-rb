#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"

# Set up paths
test_dir = File.expand_path("./tmp/integration_test")
test_file = "#{test_dir}/test_component.rb"

# Configure
Tailwindcss.configure do |config|
  config.mode = :development
  config.compiler.assets_path = "#{test_dir}/assets"
  config.compiler.output_file_name = "test"
  config.compiler.compile_classes_dir = "#{test_dir}/cache"
  config.content = ["#{test_dir}/**/*.rb"]
end

# Create Output instance and debug
output = Tailwindcss::Compiler::Output.new

puts "Content paths:"
output.content.each { |p| puts "  - #{p}" }

puts "\nCompile classes dir: #{output.compile_classes_dir}"

# Try to determine output path for our test file
output_path = output.output_file_path(file_path: test_file)
puts "\nOutput path for #{test_file}:"
puts "  #{output_path}"

# Try adding an entry
extractor = Tailwindcss::Compiler::FileClassesExtractor.new
classes = extractor.call(file_path: test_file)
puts "\nClasses extracted: #{classes.size}"

output.add_entry(file_path: test_file, classes: classes)
puts "\nEntry added. Check for .classes files in: #{test_dir}/cache"