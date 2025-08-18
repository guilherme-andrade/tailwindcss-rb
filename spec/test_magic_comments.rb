#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"
require "fileutils"

# Create test environment
test_dir = "./tmp/magic_comment_test"
FileUtils.rm_rf(test_dir)
FileUtils.mkdir_p(test_dir)

# Create a component with magic comments
File.write("#{test_dir}/button_component.rb", <<~RUBY)
  module ViewComponentUI
    class ButtonComponent
      include Tailwindcss::Helpers
      
      # @tw-whitelist bg-primary-500 bg-primary-600 hover:bg-primary-700
      # @tw-whitelist bg-secondary-500 bg-secondary-600 hover:bg-secondary-700
      # @tw-whitelist bg-success-500 bg-danger-500 bg-warning-500
      # @tw-whitelist text-primary-500 border-primary-500
      
      default_props color_scheme: :primary
      
      variant :solid,
        # @tw-whitelist bg-primary-50 bg-primary-100
        bg: proc { props_color_scheme_token(500) },
        _hover: { bg: proc { props_color_scheme_token(600) } }
      
      def render
        style(bg: color_token(:blue, 500), text: :white)
      end
    end
  end
RUBY

# Configure Tailwindcss
Tailwindcss.configure do |config|
  config.mode = :development
  config.content = ["#{test_dir}/**/*.rb"]
  config.compiler.compile_classes_dir = "#{test_dir}/cache"
  config.compiler.assets_path = "#{test_dir}/assets"
  config.compiler.output_file_name = "output"
  config.watch_content = false
end

puts "Testing Magic Comment Extraction"
puts "=" * 60

# Run extraction
require "tailwindcss/compiler/file_classes_extractor"
extractor = Tailwindcss::Compiler::FileClassesExtractor.new
classes = extractor.call(file_path: "#{test_dir}/button_component.rb")

puts "\nExtracted classes:"
puts "-" * 40

# Group classes by type for better readability
magic_classes = classes.select { |c| c.include?("primary") || c.include?("secondary") || c.include?("success") || c.include?("danger") || c.include?("warning") }
regular_classes = classes - magic_classes

puts "\nFrom magic comments (@tw-whitelist):"
magic_classes.each { |c| puts "  - #{c}" }

puts "\nFrom AST analysis:"
regular_classes.each { |c| puts "  - #{c}" }

puts "\nTotal: #{classes.count} classes"

# Now run the full compilation to see if they're included
puts "\n\nRunning full compilation..."
puts "-" * 40

runner = Tailwindcss::Compiler::Runner.new
runner.call

# Check the .classes file
classes_file = "#{test_dir}/cache/button_component.rb.classes"
if File.exist?(classes_file)
  file_content = File.read(classes_file)
  puts "\nContent of .classes file:"
  puts file_content.split("\n").first(20).join("\n")
  
  # Verify our magic comment classes are there
  expected = ["bg-primary-500", "bg-primary-600", "hover:bg-primary-700", "bg-secondary-500"]
  found = expected.select { |c| file_content.include?(c) }
  
  puts "\n\nVerification:"
  if found.length == expected.length
    puts "✅ All magic comment classes were extracted!"
  else
    puts "⚠️  Some classes missing:"
    (expected - found).each { |c| puts "  Missing: #{c}" }
  end
end

# Clean up
FileUtils.rm_rf(test_dir)