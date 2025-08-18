#!/usr/bin/env ruby
require "bundler/setup"
require "tailwindcss"
require "fileutils"

# Create test environment
test_dir = "./tmp/config_test"
FileUtils.rm_rf(test_dir)
FileUtils.mkdir_p(test_dir)

# Create a test component
test_file = "#{test_dir}/test.rb"
File.write(test_file, <<~RUBY)
  class TestComponent
    include Tailwindcss::Helpers
    
    def styles
      # Test prefix
      style(bg: color_token(:blue, 500), p: 4)
    end
    
    def dark_styles  
      # Test dark mode
      dark(bg: color_token(:gray, 900), text: :white)
    end
    
    def important_styles
      # Should be marked as important
      style(text: color_token(:red, 600))
    end
  end
RUBY

puts "Testing Tailwind Configuration Options\n"
puts "=" * 40

# Test 1: Prefix
puts "\nTest 1: Prefix Configuration"
Tailwindcss.configure do |config|
  config.mode = :development
  config.compiler.assets_path = "#{test_dir}/assets"
  config.compiler.output_file_name = "prefix_test"
  config.compiler.compile_classes_dir = "#{test_dir}/cache"
  config.content = ["#{test_dir}/**/*.rb"]
  config.prefix = "tw"
  config.watch_content = false
end

runner = Tailwindcss::Compiler::Runner.new
runner.call

css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css = File.read(css_file)
  if css.include?(".tw-bg-blue-500")
    puts "✅ Prefix 'tw' applied correctly"
  else
    puts "❌ Prefix not applied (looking for .tw-bg-blue-500)"
  end
end

# Test 2: Dark Mode
puts "\nTest 2: Dark Mode Configuration"
Tailwindcss.configure do |config|
  config.darkMode = "media" # Change from default 'class' to 'media'
  config.prefix = "" # Reset prefix
  config.compiler.output_file_name = "darkmode_test"
end

runner = Tailwindcss::Compiler::Runner.new
runner.call

css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css = File.read(css_file)
  if css.include?("@media (prefers-color-scheme: dark)")
    puts "✅ Dark mode set to 'media' correctly"
  elsif css.include?(".dark\\:")
    puts "❌ Dark mode still using 'class' strategy"
  else
    puts "⚠️  Could not verify dark mode setting"
  end
end

# Test 3: Safelist
puts "\nTest 3: Safelist Configuration"
Tailwindcss.configure do |config|
  config.compiler.output_file_name = "safelist_test"
  config.safelist = ["bg-yellow-400", "text-purple-700", "animate-spin"]
end

runner = Tailwindcss::Compiler::Runner.new
runner.call

css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css = File.read(css_file)
  safelisted = [
    css.include?("bg-yellow-400"),
    css.include?("text-purple-700"),
    css.include?("animate-spin")
  ]
  
  if safelisted.all?
    puts "✅ All safelisted classes included"
  else
    puts "❌ Some safelisted classes missing"
    puts "  bg-yellow-400: #{safelisted[0] ? '✓' : '✗'}"
    puts "  text-purple-700: #{safelisted[1] ? '✓' : '✗'}"
    puts "  animate-spin: #{safelisted[2] ? '✓' : '✗'}"
  end
end

# Test 4: Important
puts "\nTest 4: Important Configuration"
Tailwindcss.configure do |config|
  config.compiler.output_file_name = "important_test"
  config.important = true
  config.safelist = [] # Reset safelist
end

runner = Tailwindcss::Compiler::Runner.new
runner.call

css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css = File.read(css_file)
  if css.include?("!important")
    puts "✅ Important flag applied to styles"
  else
    puts "❌ Important flag not applied"
  end
end

# Test 5: Custom breakpoints
puts "\nTest 5: Custom Breakpoints"
Tailwindcss.configure do |config|
  config.compiler.output_file_name = "breakpoints_test"
  config.important = false # Reset
  config.breakpoints = {
    'xs': '475px',
    'sm': '640px',
    'md': '768px',
    'lg': '1024px',
    'xl': '1280px',
    '2xl': '1536px',
    '3xl': '1920px'
  }
end

# Add a component that uses the custom breakpoint
File.write("#{test_dir}/responsive.rb", <<~RUBY)
  class ResponsiveComponent
    include Tailwindcss::Helpers
    
    def responsive_styles
      at(:xs, display: :block) + at('3xl', display: :none)
    end
  end
RUBY

runner = Tailwindcss::Compiler::Runner.new
runner.call

css_file = Tailwindcss.output_path
if File.exist?(css_file)
  css = File.read(css_file)
  has_xs = css.include?("@media (min-width: 475px)")
  has_3xl = css.include?("@media (min-width: 1920px)")
  
  if has_xs && has_3xl
    puts "✅ Custom breakpoints (xs, 3xl) configured"
  else
    puts "❌ Custom breakpoints not properly configured"
    puts "  xs (475px): #{has_xs ? '✓' : '✗'}"
    puts "  3xl (1920px): #{has_3xl ? '✓' : '✗'}"
  end
end

# Clean up
FileUtils.rm_rf(test_dir)

puts "\n✨ Configuration tests completed!"