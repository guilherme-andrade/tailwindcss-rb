#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"

# Simulate the ViewComponentUI paths
test_paths = [
  "../view-component-ui/app/components/**/*.rb",
  "../view-component-ui/app/components/**/*.erb",
  "../view-component-ui/app/views/**/*.html.erb",
  "../view-component-ui/spec/components/previews/**/*.rb",
  "../view-component-ui/spec/components/previews/**/*.html.erb"
]

puts "Testing ViewComponentUI path extraction\n"
puts "=" * 60

test_paths.each do |path|
  puts "\nTesting path: #{path}"
  puts "Absolute path: #{File.expand_path(path)}"
  
  # Test what Dir.glob finds
  files = Dir.glob(path)
  abs_files = Dir.glob(File.expand_path(path))
  
  puts "Files found with relative path: #{files.count}"
  puts "Files found with absolute path: #{abs_files.count}"
  
  if abs_files.any?
    puts "Sample files:"
    abs_files.first(3).each { |f| puts "  - #{f}" }
  end
end

# Now test with the actual configuration
puts "\n\nTesting with Tailwindcss configuration:"
puts "=" * 60

Tailwindcss.configure do |config|
  config.mode = :development
  config.content = test_paths.map { |p| File.expand_path(p) }
  config.compiler.compile_classes_dir = "./tmp/test_extraction"
  config.compiler.assets_path = "./tmp/test_extraction"
  config.compiler.output_file_name = "output"
  config.watch_content = false
end

# Run the extraction
require "tailwindcss/compiler/runner"
require "tailwindcss/compiler/file_classes_extractor"

extractor = Tailwindcss::Compiler::FileClassesExtractor.new
runner = Tailwindcss::Compiler::Runner.new

# Check what content paths are being used
puts "\nConfigured content paths:"
Tailwindcss.resolve_setting(Tailwindcss.config.content).each do |path|
  puts "  - #{path}"
  glob_pattern = if path.to_s.include?('*')
    path.to_s
  else
    File.directory?(path.to_s) ? "#{path}/**/*" : path.to_s
  end
  
  files = Dir.glob(glob_pattern)
  puts "    Found #{files.count} files"
end

# Try to extract from a specific file if one exists
sample_file = Dir.glob(File.expand_path("../view-component-ui/app/components/**/*.rb")).first
if sample_file
  puts "\n\nTesting extraction from: #{sample_file}"
  begin
    classes = extractor.call(file_path: sample_file)
    puts "Extracted classes: #{classes.inspect}"
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace.first(5)
  end
end

# Run the full runner
puts "\n\nRunning full extraction..."
runner.call

# Check what was extracted
cache_dir = "./tmp/test_extraction"
if Dir.exist?(cache_dir)
  classes_files = Dir.glob("#{cache_dir}/**/*.classes")
  puts "Created #{classes_files.count} .classes files"
  
  if classes_files.any?
    puts "\nSample .classes files:"
    classes_files.first(3).each do |file|
      puts "  #{file}:"
      puts "    #{File.read(file).split("\n").first(5).join(', ')}..."
    end
  end
end