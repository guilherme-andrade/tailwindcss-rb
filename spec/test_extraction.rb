#!/usr/bin/env ruby
# Debug class extraction

require "bundler/setup"
require "tailwindcss"

extractor = Tailwindcss::Compiler::FileClassesExtractor.new
button_classes = extractor.call(file_path: "spec/dummy_rails_app/app/components/button_component.rb")

puts "Extracted classes from ButtonComponent:"
puts button_classes.inspect
puts "\nTotal classes: #{button_classes.size}"

# Let's also check what the file parser sees
parser = Tailwindcss::Compiler::FileParser.new
ast_nodes = parser.call(file_path: "spec/dummy_rails_app/app/components/button_component.rb")

puts "\nAST nodes found:"
puts ast_nodes.inspect