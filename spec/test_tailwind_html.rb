#!/usr/bin/env ruby
require "fileutils"
require "json"

# Create test environment
test_dir = "./tmp/tailwind_html_test"
FileUtils.rm_rf(test_dir)
FileUtils.mkdir_p(test_dir)

# Create an HTML file with Tailwind classes
html_file = "#{test_dir}/test.html"
File.write(html_file, <<~HTML)
  <div class="bg-blue-500 p-4 text-white hover:bg-blue-600">
    Test content
  </div>
HTML

puts "Testing Tailwind with HTML file\n"
puts "=" * 40
puts "\nHTML file contents:"
puts File.read(html_file)

# Create a simple Tailwind config
config = {
  content: ["#{test_dir}/**/*.html"],
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
  ["tw-bg-blue-500", "tw-p-4", "tw-text-white", "hover\\:tw-bg-blue-600"].each do |cls|
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
  
  # Show sample utility classes
  puts "\nSample of generated classes:"
  tw_lines = css.split("\n").select { |line| line.include?(".tw-") && line.include?("{") }
  tw_lines.first(5).each { |line| puts line }
else
  puts "CSS file not created!"
end

# Clean up
FileUtils.rm_rf(test_dir)