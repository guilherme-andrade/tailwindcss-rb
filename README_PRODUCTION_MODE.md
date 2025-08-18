# Using tailwindcss-rb in Production Mode

When using tailwindcss-rb with `config.mode = :production`, the automatic class extraction is skipped for performance reasons. This is common when using the gem in a library or gem that needs to compile its own CSS.

## Solution

You have two options to extract classes before compiling:

### Option 1: Call extract_classes! manually

```ruby
# In your Rakefile or compile script
require 'tailwindcss'

# Your configuration...
Tailwindcss.configure do |config|
  config.mode = :production
  config.content = [
    "app/components/**/*.rb",
    "app/views/**/*.erb"
  ]
  # ... rest of config
end

# Force extraction even in production mode
Tailwindcss.extract_classes!

# Then compile CSS
Tailwindcss.compile_css!
```

### Option 2: Use the provided Rake tasks

First, require the tasks in your Rakefile:

```ruby
# Rakefile
require 'tailwindcss/tasks'
```

Then use the tasks:

```bash
# Extract and compile in one step
rake tailwindcss:compile

# Or separately:
rake tailwindcss:extract
rake tailwindcss:compile
```

### Option 3: Set mode to development during compilation

```ruby
# Temporarily switch to development mode for compilation
Tailwindcss.config.mode = :development
Tailwindcss.init!  # This will run extraction
Tailwindcss.compile_css!
Tailwindcss.config.mode = :production  # Switch back if needed
```

## For ViewComponentUI and similar libraries

If you're building a component library, you might want to create a custom rake task:

```ruby
# lib/tasks/tailwindcss.rake
namespace :tailwindcss do
  desc "Compile Tailwind CSS for component library"
  task :compile do
    require 'your_library'
    require 'tailwindcss'
    
    # Configure Tailwindcss
    YourLibrary.configure_tailwindcss
    
    # Extract classes and compile
    Tailwindcss.extract_classes!
    Tailwindcss.compile_css!
    
    puts "✅ Tailwind CSS compiled successfully!"
  end
end
```

## Important Notes

1. The `extract_classes!` method forces class extraction regardless of the mode setting
2. Extraction creates `.classes` files in your configured `compile_classes_dir`
3. These files are then read by Tailwind CLI during compilation
4. Make sure your `config.content` paths include all files with Tailwind classes