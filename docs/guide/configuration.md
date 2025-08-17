# Configuration

## Configuration File

Configure tailwindcss-rb by creating an initializer file in your Rails application:

```ruby
# config/initializers/tailwindcss.rb

Tailwindcss.configure do |config|
  # Core settings
  config.content = []
  config.prefix = ""
  
  # Compiler settings
  config.compiler.output_path = "./public/assets/styles.css"
  config.compiler.compile_classes_dir = "./tmp/tailwindcss"
  
  # Tailwind configuration
  config.package_json_path = "./package.json"
  config.config_file_path = "./tailwind.config.js"
  
  # Development settings
  config.watch_content = false
  config.logger = Logger.new(STDOUT)
  
  # Theme configuration
  config.theme.color_scheme = {}
  
  # Responsive breakpoints
  config.breakpoints = %i[xs sm md lg xl 2xl]
  
  # Pseudo selectors and elements
  config.pseudo_selectors = %i[hover focus active visited disabled]
  config.pseudo_elements = %i[before after]
end
```

## Configuration Options

### Content Paths

Specify which files to scan for Tailwind classes:

```ruby
config.content = [
  "app/views/**/*.html.erb",
  "app/helpers/**/*.rb",
  "app/components/**/*.rb",
  "app/javascript/**/*.js"
]
```

### Compiler Settings

#### Output Path

Where the compiled CSS file will be saved:

```ruby
config.compiler.output_path = "./app/assets/stylesheets/tailwind.css"
```

#### Classes Directory

Temporary directory for extracted classes:

```ruby
config.compiler.compile_classes_dir = "./tmp/tailwindcss"
```

### Prefix

Add a prefix to all generated classes:

```ruby
config.prefix = "tw-"
# tailwind(bg: :blue) => "tw-bg-blue-500"
```

### Watch Mode

Enable file watching for automatic recompilation:

```ruby
config.watch_content = true # Enable in development
```

### Logging

Configure logging output:

```ruby
# Use Rails logger
config.logger = Rails.logger

# Custom log level
config.logger = Logger.new(STDOUT).tap do |log|
  log.level = Logger::DEBUG
end

# Disable logging
config.logger = Logger.new(nil)
```

## Theme Configuration

### Color Schemes

Define custom color schemes for your application:

```ruby
config.theme.color_scheme = {
  primary: :blue,
  secondary: :green,
  danger: :red,
  warning: :yellow,
  info: :cyan,
  success: :emerald
}
```

Use in your code:

```ruby
tailwind(bg: color_scheme_token(:primary))
# => "bg-blue-500"

tailwind(bg: color_scheme_token(:primary, 600))
# => "bg-blue-600"
```

### Custom Breakpoints

Define responsive breakpoints:

```ruby
config.breakpoints = %i[
  xs    # 0px
  sm    # 640px
  md    # 768px
  lg    # 1024px
  xl    # 1280px
  2xl   # 1536px
]
```

### Pseudo Selectors

Configure available pseudo selectors:

```ruby
config.pseudo_selectors = %i[
  hover
  focus
  active
  visited
  disabled
  first
  last
  odd
  even
  group_hover
  focus_within
  focus_visible
]
```

### Pseudo Elements

Configure available pseudo elements:

```ruby
config.pseudo_elements = %i[
  before
  after
  first_letter
  first_line
  selection
  backdrop
  marker
  placeholder
]
```

## Environment-Specific Configuration

### Development Configuration

```ruby
if Rails.env.development?
  config.watch_content = true
  config.logger.level = Logger::DEBUG
  config.compiler.output_path = "./tmp/tailwind-dev.css"
end
```

### Production Configuration

```ruby
if Rails.env.production?
  config.watch_content = false
  config.logger.level = Logger::ERROR
  config.compiler.output_path = "./public/assets/tailwind-#{digest}.css"
  
  # CDN configuration
  config.tailwind_css_file_path = proc {
    "https://cdn.example.com/assets/tailwind.css"
  }
end
```

## Advanced Configuration

### Custom Tailwind Config Path

```ruby
config.config_file_path = Rails.root.join("config", "tailwind.config.js")
```

### Package.json Location

```ruby
config.package_json_path = Rails.root.join("package.json")
```

### Asset Pipeline Integration

```ruby
# For Sprockets
config.compiler.output_path = Rails.root.join(
  "app", "assets", "stylesheets", "tailwind.css"
)

# For Webpacker/Shakapacker
config.compiler.output_path = Rails.root.join(
  "app", "javascript", "stylesheets", "tailwind.css"
)
```

## Troubleshooting Configuration

### Classes Not Generating

1. Verify content paths include your files
2. Check compiler output path is writable
3. Ensure cache directory exists and is writable

### Performance Issues

```ruby
# Optimize content paths
config.content = [
  "app/views/**/*.erb",  # More specific
  "app/components/**/*.rb"
]

# Enable caching
config.compiler.cache_enabled = true
```

### Debug Mode

```ruby
config.debug = true
config.logger.level = Logger::DEBUG
```

## Next Steps

- Set up [Development](./development) workflow
- Configure [Production](./production) deployment
- Learn about [CDN Setup](./cdn) for assets