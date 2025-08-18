#!/usr/bin/env ruby
require "fileutils"
require "json"

# Create test environment
test_dir = "./tmp/tailwind_direct_test"
FileUtils.rm_rf(test_dir)
FileUtils.mkdir_p("#{test_dir}/cache")

# Create a simple .classes file with Tailwind classes
classes_file = "#{test_dir}/cache/test.classes"
File.write(classes_file, "bg-blue-500\np-4\ntext-white\nhover:bg-blue-600")

puts "Testing Direct Tailwind Compilation\n"
puts "=" * 40
puts "\nClasses file contents:"
puts File.read(classes_file)

# Create a simple Tailwind config
config = {
  content: ["#{test_dir}/cache/**/*.classes"],
  prefix: "tw-",
  important: true
}

puts "\nTailwind config:"
puts JSON.pretty_generate(config)

# Write config file
config_file = "#{test_dir}/tailwind.config.js"
File.write(config_file, "module.exports = #{config.to_json}")

# Run Tailwind
css_file = "#{test_dir}/output.css"
cmd = ["npx", "tailwindcss", "-o", css_file, "-c", config_file]
puts "\nRunning: #{cmd.join(' ')}"
system(*cmd)

# Check output
if File.exist?(css_file)
  css = File.read(css_file)
  
  puts "\nChecking CSS output:"
  puts "-" * 40
  
  # Check for prefixed classes
  ["tw-bg-blue-500", "tw-p-4", "tw-text-white"].each do |cls|
    if css.include?(".#{cls}")
      puts "✅ Found: .#{cls}"
    else
      puts "❌ Missing: .#{cls}"
    end
  end
  
  # Check for important
  if css.include?("!important")
    puts "✅ Important flag applied"
  else
    puts "❌ Important flag not found"
  end
  
  # Show a sample of utility classes
  puts "\nSearching for any tw- prefixed classes..."
  tw_lines = css.split("\n").select { |line| line.include?(".tw-") }
  if tw_lines.any?
    puts "Found #{tw_lines.length} lines with .tw- classes"
    tw_lines.first(5).each { |line| puts line }
  else
    puts "No .tw- prefixed classes found in CSS"
    
    # Check if any classes were generated at all
    bg_lines = css.split("\n").select { |line| line.include?("bg-") }
    if bg_lines.any?
      puts "\nFound unprefixed bg- classes instead:"
      bg_lines.first(3).each { |line| puts line }
    end
  end
  
  # Check file size
  puts "\nCSS file size: #{File.size(css_file)} bytes"
else
  puts "CSS file not created!"
end

# Clean up
FileUtils.rm_rf(test_dir)