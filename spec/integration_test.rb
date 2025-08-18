#!/usr/bin/env ruby
# Simple integration test runner for the compiler

require "bundler/setup"
require "tailwindcss"
require "fileutils"
require "json"

# Configure TailwindCSS for testing
Tailwindcss.configure do |config|
  config.mode = :development
  config.compiler.assets_path = "./tmp/test_assets"
  config.compiler.output_file_name = "test_output"
  config.compiler.compile_classes_dir = "./tmp/test_cache"
  config.content = [
    "./spec/dummy_rails_app/app/**/*.rb",
    "./spec/dummy_rails_app/app/**/*.erb"
  ]
end

puts "Running Compiler Integration Tests...\n\n"

# Test 1: Class Extraction from Ruby Files
puts "Test 1: Class Extraction from Ruby Components"
extractor = Tailwindcss::Compiler::FileClassesExtractor.new
button_classes = extractor.call(file_path: "spec/dummy_rails_app/app/components/button_component.rb")

expected_classes = ["px-4", "py-2", "rounded-lg", "font-medium", "bg-blue-500", "text-white", "hover:bg-blue-600"]
missing_classes = expected_classes - button_classes

if missing_classes.empty?
  puts "✅ Successfully extracted all expected classes from ButtonComponent"
else
  puts "❌ Missing classes: #{missing_classes.join(', ')}"
end

# Test 2: Class Extraction from ERB Templates
puts "\nTest 2: Class Extraction from ERB Templates"
erb_classes = extractor.call(file_path: "spec/dummy_rails_app/app/views/components/_button.html.erb")

expected_erb_classes = ["disabled:opacity-50", "disabled:cursor-not-allowed", "inline-flex", "items-center", "gap-2", "w-4", "h-4"]
missing_erb_classes = expected_erb_classes - erb_classes

if missing_erb_classes.empty?
  puts "✅ Successfully extracted all expected classes from ERB template"
else
  puts "❌ Missing classes: #{missing_erb_classes.join(', ')}"
end

# Test 3: Dark Mode Classes
puts "\nTest 3: Dark Mode Class Extraction"
card_classes = extractor.call(file_path: "spec/dummy_rails_app/app/components/card_component.rb")

dark_classes = card_classes.select { |c| c.start_with?("dark:") }
if dark_classes.include?("dark:bg-gray-800") && dark_classes.include?("dark:text-white")
  puts "✅ Successfully extracted dark mode classes"
else
  puts "❌ Failed to extract dark mode classes"
end

# Test 4: Responsive Classes
puts "\nTest 4: Responsive Class Extraction"
responsive_classes = card_classes.select { |c| c.match?(/^(sm|md|lg|xl):/) }

if responsive_classes.include?("sm:p-4") && responsive_classes.include?("md:p-6") && responsive_classes.include?("lg:p-8")
  puts "✅ Successfully extracted responsive classes"
else
  puts "❌ Failed to extract responsive classes"
end

# Test 5: Color Weight Notation
puts "\nTest 5: Color Weight Notation"
if button_classes.include?("bg-blue-500") && button_classes.include?("hover:bg-blue-600")
  puts "✅ Successfully handled color weight notation"
else
  puts "❌ Failed to handle color weight notation"
end

# Test 6: Caching Behavior
puts "\nTest 6: AST Caching"
cache_dir = Tailwindcss.resolve_setting(Tailwindcss.config.compiler.compile_classes_dir)
FileUtils.mkdir_p(cache_dir)

cache = Tailwindcss::Compiler::AstCache.new
test_file = "spec/dummy_rails_app/app/components/button_component.rb"

# First call should cache
result1 = cache.fetch(test_file) { extractor.call(file_path: test_file) }
# Second call should use cache
cached = false
result2 = cache.fetch(test_file) do
  cached = true
  []
end

if !cached && result1 == result2
  puts "✅ Caching works correctly"
else
  puts "❌ Caching not working as expected"
end

# Test 7: Compilation Process
puts "\nTest 7: CSS Compilation"
begin
  runner = Tailwindcss::Compiler::Runner.new
  runner.call
  
  output_path = Tailwindcss.output_path
  if File.exist?(output_path)
    css_content = File.read(output_path)
    if css_content.include?(".px-4") && css_content.include?(".bg-blue-500")
      puts "✅ CSS compiled successfully with extracted classes"
    else
      puts "❌ CSS file missing expected classes"
    end
  else
    puts "❌ CSS file not generated"
  end
rescue => e
  puts "❌ Compilation failed: #{e.message}"
end

# Test 8: Production/Development Mode
puts "\nTest 8: Mode Detection"
if Tailwindcss.development_mode? && !Tailwindcss.production_mode?
  puts "✅ Correctly in development mode"
else
  puts "❌ Mode detection issue"
end

# Clean up test files
FileUtils.rm_rf("./tmp/test_assets")
FileUtils.rm_rf("./tmp/test_cache")

puts "\n✨ Integration tests completed!"