# Using Rake Tasks with tailwindcss-rb

The gem provides rake tasks for compiling Tailwind CSS. These tasks work with Rails, other Ruby frameworks, and standalone Ruby projects.

## Setup

### For Rails Applications

The tasks will automatically load your Rails environment. Just require the tasks in your Rakefile:

```ruby
# Rakefile
require 'tailwindcss/tasks'
```

Your Tailwindcss configuration should be in an initializer:

```ruby
# config/initializers/tailwindcss.rb
Tailwindcss.configure do |config|
  # your configuration
end
```

### For Ruby Gems/Engines (like ViewComponentUI)

For gems and engines, the tasks will look for configuration in these locations (in order):
1. `config/environment.rb`
2. `config/application.rb`
3. `lib/tailwindcss_init.rb`
4. `config/tailwindcss.rb`

You can either:

**Option 1: Create a configuration file**

```ruby
# config/tailwindcss.rb or lib/tailwindcss_init.rb
require 'your_gem'  # Load your gem first
require 'tailwindcss'

Tailwindcss.configure do |config|
  config.content = [
    "app/components/**/*.rb",
    # ... your paths
  ]
  # ... rest of config
end
```

**Option 2: Load configuration in your Rakefile**

```ruby
# Rakefile
require 'bundler/setup'
require 'your_gem'
require 'tailwindcss/tasks'

# Configure Tailwindcss before the tasks run
load 'path/to/your/tailwindcss/config.rb'
```

**Option 3: Override the environment task**

```ruby
# Rakefile
require 'tailwindcss/tasks'

# Override the environment task to load your configuration
Rake::Task['tailwindcss:environment'].clear
task 'tailwindcss:environment' do
  require 'your_gem'
  # Load your Tailwindcss configuration
  YourGem.load_tailwindcss_config
end
```

### For Standalone Ruby Projects

Create a configuration file that the tasks will automatically load:

```ruby
# config/tailwindcss.rb
require 'tailwindcss'

Tailwindcss.configure do |config|
  config.content = ["src/**/*.rb"]
  # ... your configuration
end
```

## Available Tasks

### `rake tailwindcss:compile`

Extracts Tailwind classes from your Ruby/ERB files and compiles CSS:

```bash
$ rake tailwindcss:compile
Compiling Tailwind CSS...
Mode: development

Step 1: Extracting classes...
  → Extracted 45 .classes files

Step 2: Compiling CSS...
  → CSS compiled to app/assets/stylesheets/application.css (16384 bytes)

✅ Compilation complete!
```

### `rake tailwindcss:extract`

Only extracts classes without compiling CSS:

```bash
$ rake tailwindcss:extract
```

### `rake tailwindcss:watch`

Watches for file changes and automatically recompiles:

```bash
$ rake tailwindcss:watch
```

## Troubleshooting

### Configuration Not Loading

If your configuration isn't being loaded:

1. Check that your configuration file is in one of the expected locations
2. Or explicitly load it in your Rakefile before requiring the tasks
3. Or override the `tailwindcss:environment` task

### Production Mode Issues

If extraction is skipped in production mode, you can force it:

```ruby
# In your configuration
Tailwindcss.configure do |config|
  config.mode = :development  # Force development mode for compilation
  # ... rest of config
end
```

Or call `extract_classes!` directly:

```ruby
# In a custom rake task
task :compile_production do
  Tailwindcss.extract_classes!  # Force extraction
  Tailwindcss.compile_css!
end
```