# frozen_string_literal: true

namespace :tailwindcss do
  desc "Extract Tailwind classes from Ruby/ERB files"
  task :extract do
    require "tailwindcss"
    require "tailwindcss/compiler/runner"
    
    puts "Extracting Tailwind classes..."
    
    # Force extraction even in production mode
    runner = Tailwindcss::Compiler::Runner.new
    runner.call
    
    puts "Extraction complete!"
  end
  
  desc "Compile Tailwind CSS (runs extraction first)"
  task :compile => :extract do
    require "tailwindcss"
    
    puts "Compiling Tailwind CSS..."
    Tailwindcss.compile_css!
    puts "Compilation complete!"
  end
  
  desc "Watch for changes and recompile"
  task :watch do
    require "tailwindcss"
    require "tailwindcss/compiler/runner"
    
    puts "Watching for changes..."
    
    # Force watch mode
    runner = Tailwindcss::Compiler::Runner.new(watch: true)
    runner.call
    
    # Keep the process running
    sleep
  end
end