#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"
require "fileutils"
require "json"

# Create test environment
test_dir = "./tmp/css_output_test"
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

puts "Testing CSS Output\n"
puts "=" * 40

# Configure with prefix and important
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

# Run the compiler
runner = Tailwindcss::Compiler::Runner.new
runner.call

# Check the classes file
classes_file = "#{test_dir}/cache/test.rb.classes"
if File.exist?(classes_file)
  puts "\nClasses file contents:"
  puts File.read(classes_file)
end

# Now manually run Tailwind with the config to see what happens
content_paths = ["#{test_dir}/**/*.rb", "#{test_dir}/cache/**/*.classes"]

config = {
  content: content_paths,
  prefix: "tw-",
  important: true
}

puts "\nConfig being passed to Tailwind:"
puts JSON.pretty_generate(config)

# Create temp config and run Tailwind
require 'tempfile'
Tempfile.create(['tailwind', '.config.js']) do |f|
  f.write("module.exports = #{config.to_json}")
  f.flush
  
  css_file = "#{test_dir}/assets/test_output.css"
  FileUtils.mkdir_p("#{test_dir}/assets")
  
  cmd = ["npx", "tailwindcss", "-o", css_file, "-c", f.path]
  puts "\nRunning: #{cmd.join(' ')}"
  
  result = system(*cmd)
  
  if File.exist?(css_file)
    css = File.read(css_file)
    
    puts "\n\nAnalyzing CSS output:"
    puts "-" * 40
    
    # Check for our classes with prefix
    ["tw-bg-blue-500", "tw-p-4", "tw-text-white"].each do |cls|
      if css.include?(".#{cls}")
        puts "✅ Found class: .#{cls}"
      else
        puts "❌ Missing class: .#{cls}"
      end
    end
    
    # Check for important
    if css.include?("!important")
      puts "✅ Important flag applied"
    else
      puts "❌ Important flag not found"
    end
    
    # Show a sample of the CSS
    utility_section = css.split("\n").select { |line| line.include?(".tw-") }
    if utility_section.any?
      puts "\nSample of utility classes:"
      utility_section.first(5).each { |line| puts line }
    else
      # Show any bg- classes
      bg_classes = css.split("\n").select { |line| line.include?("bg-") }
      if bg_classes.any?
        puts "\nFound unprefixed bg- classes (should have tw- prefix):"
        bg_classes.first(3).each { |line| puts line }
      end
    end
  else
    puts "CSS file not created at #{css_file}"
  end
end

# Clean up
FileUtils.rm_rf(test_dir)