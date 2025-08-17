# Configuration API

Complete reference for configuring tailwindcss-rb in your application.

## Configuration Block

```ruby
Tailwindcss.configure do |config|
  # Configuration options
end
```

## Core Configuration

### content

Paths to scan for Tailwind class usage.

```ruby
config.content = [
  "app/views/**/*.html.erb",
  "app/helpers/**/*.rb",
  "app/components/**/*.rb"
]
```

**Type:** `Array<String>`  
**Default:** `[]`

### prefix

Prefix for all generated Tailwind classes.

```ruby
config.prefix = "tw-"
# tailwind(bg: :blue) => "tw-bg-blue-500"
```

**Type:** `String`  
**Default:** `""`

### watch_content

Enable file watching for automatic recompilation.

```ruby
config.watch_content = true
```

**Type:** `Boolean`  
**Default:** `false`

### logger

Logger instance for debugging and information.

```ruby
config.logger = Rails.logger
# or
config.logger = Logger.new(STDOUT)
```

**Type:** `Logger`  
**Default:** `Logger.new(STDOUT)`

## Compiler Configuration

### compiler.output_path

Path where compiled CSS will be saved.

```ruby
config.compiler.output_path = "./app/assets/stylesheets/tailwind.css"
```

**Type:** `String`  
**Default:** `"./public/assets/styles.css"`

### compiler.compile_classes_dir

Directory for temporary class extraction files.

```ruby
config.compiler.compile_classes_dir = "./tmp/tailwindcss"
```

**Type:** `String`  
**Default:** `"./tmp/tailwindcss"`

### compiler.cache_enabled

Enable caching for improved performance.

```ruby
config.compiler.cache_enabled = true
```

**Type:** `Boolean`  
**Default:** `true`

## Tailwind Configuration

### config_file_path

Path to Tailwind configuration file.

```ruby
config.config_file_path = "./tailwind.config.js"
```

**Type:** `String`  
**Default:** `"./tailwind.config.js"`

### package_json_path

Path to package.json file.

```ruby
config.package_json_path = "./package.json"
```

**Type:** `String`  
**Default:** `"./package.json"`

### tailwind_css_file_path

URL or path to the compiled CSS file for production.

```ruby
# Static path
config.tailwind_css_file_path = "/assets/tailwind.css"

# Dynamic with proc
config.tailwind_css_file_path = proc {
  "https://cdn.example.com/assets/tailwind-#{digest}.css"
}
```

**Type:** `String | Proc`  
**Default:** Based on `compiler.output_path`

## Theme Configuration

### theme.color_scheme

Define semantic color mappings.

```ruby
config.theme.color_scheme = {
  primary: :blue,
  secondary: :green,
  danger: :red,
  warning: :yellow,
  info: :cyan,
  success: :emerald,
  neutral: :gray
}
```

**Type:** `Hash<Symbol, Symbol>`  
**Default:** `{}`

**Usage:**
```ruby
tailwind(bg: color_scheme_token(:primary))
# => "bg-blue-500"
```

### breakpoints

Available responsive breakpoints.

```ruby
config.breakpoints = %i[xs sm md lg xl 2xl]
```

**Type:** `Array<Symbol>`  
**Default:** `%i[xs sm md lg xl 2xl]`

**Breakpoint values:**
- `xs`: 0px
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

### pseudo_selectors

Available pseudo-class modifiers.

```ruby
config.pseudo_selectors = %i[
  hover focus active visited disabled
  first last odd even
  group_hover peer_checked
  focus_within focus_visible
]
```

**Type:** `Array<Symbol>`  
**Default:** Common pseudo-selectors

### pseudo_elements

Available pseudo-element modifiers.

```ruby
config.pseudo_elements = %i[
  before after
  first_letter first_line
  selection backdrop marker
  placeholder file
]
```

**Type:** `Array<Symbol>`  
**Default:** Common pseudo-elements

## Advanced Configuration

### Custom Processors

Add custom processing for specific file types.

```ruby
config.processors = {
  ".rb" => ->(content) { 
    # Custom Ruby file processing
  },
  ".slim" => ->(content) {
    # Custom Slim template processing
  }
}
```

### Hooks

Configure lifecycle hooks.

```ruby
config.on_compile_start = -> {
  puts "Starting compilation..."
}

config.on_compile_complete = ->(stats) {
  puts "Compiled #{stats[:classes_count]} classes in #{stats[:duration]}ms"
}

config.on_error = ->(error) {
  Rails.logger.error "Compilation error: #{error.message}"
}
```

## Environment-Specific Configuration

### Development Setup

```ruby
if Rails.env.development?
  Tailwindcss.configure do |config|
    config.watch_content = true
    config.logger.level = Logger::DEBUG
    config.compiler.cache_enabled = false
    config.compiler.output_path = "./tmp/tailwind-dev.css"
  end
end
```

### Production Setup

```ruby
if Rails.env.production?
  Tailwindcss.configure do |config|
    config.watch_content = false
    config.logger.level = Logger::ERROR
    config.compiler.cache_enabled = true
    
    # CDN setup
    config.tailwind_css_file_path = proc {
      asset_host = Rails.application.config.asset_host
      digest = Rails.application.assets_manifest.files.dig(
        "tailwind.css", "digest"
      )
      "#{asset_host}/assets/tailwind-#{digest}.css"
    }
  end
end
```

### Test Setup

```ruby
if Rails.env.test?
  Tailwindcss.configure do |config|
    config.logger = Logger.new(nil)  # Silence logs
    config.compiler.output_path = "./tmp/test/tailwind.css"
    config.watch_content = false
  end
end
```

## Configuration Patterns

### Multi-tenant Configuration

```ruby
class TenantConfig
  def self.for(tenant)
    Tailwindcss.configure do |config|
      config.theme.color_scheme = tenant.brand_colors
      config.prefix = "#{tenant.slug}-"
      config.compiler.output_path = "./public/#{tenant.slug}/tailwind.css"
    end
  end
end
```

### Feature Flags

```ruby
Tailwindcss.configure do |config|
  if Feature.enabled?(:dark_mode)
    config.theme.dark_mode = true
  end
  
  if Feature.enabled?(:rtl_support)
    config.theme.direction = :rtl
  end
  
  config.content = [
    "app/views/**/*.erb",
    Feature.enabled?(:new_ui) ? "app/components/v2/**/*.rb" : "app/components/v1/**/*.rb"
  ]
end
```

### Dynamic Configuration

```ruby
class DynamicConfig
  def self.load
    settings = YAML.load_file("config/tailwind_settings.yml")[Rails.env]
    
    Tailwindcss.configure do |config|
      config.content = settings["content"]
      config.theme.color_scheme = settings["colors"].symbolize_keys
      config.compiler.output_path = settings["output_path"]
    end
  end
end

# Load on initialization
DynamicConfig.load
```

## Validation

```ruby
Tailwindcss.configure do |config|
  # Validate configuration
  config.validate! do |validator|
    validator.ensure_paths_exist(:content)
    validator.ensure_writable(:compiler.output_path)
    validator.ensure_valid_colors(:theme.color_scheme)
  end
end
```

## Reset Configuration

```ruby
# Reset to defaults
Tailwindcss.reset_configuration!

# Or selectively reset
Tailwindcss.configure do |config|
  config.reset(:theme)
  config.reset(:compiler)
end
```