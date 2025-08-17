# Development Setup

Optimize your development workflow with tailwindcss-rb for rapid iteration and instant feedback.

## Watch Mode

### Starting the Watcher

Run the watcher to automatically recompile styles when files change:

```bash
bundle exec rake tailwindcss:compile:watch
```

This will:
- Monitor files in your configured `content` paths
- Recompile CSS when changes are detected
- Show compilation status and errors in the terminal

### Using with Foreman

Add to your `Procfile.dev`:

```yaml
web: bin/rails server
css: bundle exec rake tailwindcss:compile:watch
```

Then start all processes:

```bash
foreman start -f Procfile.dev
```

### Using with Overmind

In `.overmind.env`:

```bash
OVERMIND_PROCFILE=Procfile.dev
```

In `Procfile.dev`:

```yaml
web: bin/rails server
css: bundle exec rake tailwindcss:compile:watch
webpack: bin/webpack-dev-server
```

Start with:

```bash
overmind start
```

## Development Configuration

### Optimized Settings

```ruby
# config/initializers/tailwindcss.rb

if Rails.env.development?
  Tailwindcss.configure do |config|
    # Enable file watching
    config.watch_content = true
    
    # Verbose logging for debugging
    config.logger = Logger.new(STDOUT).tap do |log|
      log.level = Logger::DEBUG
    end
    
    # Fast compilation without optimization
    config.compiler.minify = false
    
    # Use source maps
    config.compiler.source_maps = true
    
    # Disable caching for immediate updates
    config.compiler.cache_enabled = false
    
    # Development-specific output
    config.compiler.output_path = Rails.root.join(
      "tmp", "cache", "assets", "tailwind.css"
    )
  end
end
```

### Content Path Optimization

```ruby
config.content = [
  # Be specific to improve performance
  "app/views/**/*.html.erb",
  "app/views/**/*.html.slim",
  "app/helpers/**/*.rb",
  "app/components/**/*.rb",
  "app/javascript/**/*.jsx",
  
  # Exclude test files
  "!app/**/*_spec.rb",
  "!app/**/*_test.rb"
]
```

## Browser Integration

### Live Reload

Install and configure `rack-livereload`:

```ruby
# Gemfile
group :development do
  gem 'rack-livereload'
  gem 'guard-livereload', require: false
end
```

```ruby
# config/environments/development.rb
config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload
```

Create `Guardfile`:

```ruby
guard 'livereload' do
  watch(%r{tmp/cache/assets/tailwind\.css})
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/components/.+\.rb$})
end
```

### Hot Module Replacement (HMR)

For Webpack/Webpacker users:

```javascript
// app/javascript/packs/application.js
if (module.hot) {
  module.hot.accept('../stylesheets/tailwind.css', () => {
    console.log('Tailwind CSS updated!')
  })
}
```

## Debugging

### Enable Debug Mode

```ruby
Tailwindcss.configure do |config|
  config.debug = true
  config.compiler.verbose = true
end
```

### Inspect Generated Classes

```bash
# View extracted classes
cat tmp/tailwindcss/*.classes

# Check cache status
ls -la tmp/tailwindcss/*.json

# Monitor compilation
tail -f log/tailwindcss.log
```

### Debug Helpers

```ruby
# app/helpers/debug_helper.rb
module DebugHelper
  def debug_tailwind(*args)
    if Rails.env.development?
      classes = tailwind(*args)
      logger.debug "Tailwind classes: #{classes}"
      content_tag :div, classes, class: "debug-output"
    else
      tailwind(*args)
    end
  end
end
```

## Performance Optimization

### Caching Strategies

```ruby
class CachedStyles
  def self.button_primary
    Rails.cache.fetch("tailwind/button/primary") do
      Tailwindcss::Style.new(
        bg: :blue,
        text: :white,
        px: 4,
        py: 2
      ).to_s
    end
  end
end
```

### Lazy Loading

```ruby
# Only compile when needed
class LazyCompiler
  def self.ensure_compiled
    return if File.exist?(output_path) && !stale?
    
    system("bundle exec rake tailwindcss:compile")
  end
  
  private
  
  def self.stale?
    source_files.any? { |f| File.mtime(f) > File.mtime(output_path) }
  end
end
```

## Testing in Development

### Component Testing

```ruby
# spec/components/button_component_spec.rb
RSpec.describe ButtonComponent do
  it "generates correct classes" do
    component = ButtonComponent.new(variant: :primary)
    expect(component.classes).to include("bg-blue-500")
  end
end
```

### Visual Testing

```erb
<!-- app/views/styleguide/components.html.erb -->
<div class="style-guide">
  <h2>Button Variants</h2>
  <% %i[primary secondary danger].each do |variant| %>
    <button class="<%= ButtonComponent.style(variant: variant) %>">
      <%= variant.to_s.capitalize %> Button
    </button>
  <% end %>
</div>
```

## Docker Development

### Dockerfile.dev

```dockerfile
FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  npm \
  postgresql-client

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY package* ./
RUN npm install

COPY . .

# Compile initial styles
RUN bundle exec rake tailwindcss:install
RUN bundle exec rake tailwindcss:compile

CMD ["bundle", "exec", "rake", "tailwindcss:compile:watch"]
```

### docker-compose.yml

```yaml
version: '3.8'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    command: bundle exec rails server -b 0.0.0.0
    volumes:
      - .:/app
      - bundle:/bundle
    ports:
      - "3000:3000"
    depends_on:
      - css
  
  css:
    build:
      context: .
      dockerfile: Dockerfile.dev
    command: bundle exec rake tailwindcss:compile:watch
    volumes:
      - .:/app
      - ./tmp/tailwindcss:/app/tmp/tailwindcss
      - ./app/assets/stylesheets:/app/app/assets/stylesheets

volumes:
  bundle:
```

## IDE Integration

### VS Code Settings

```json
{
  "tailwindCSS.experimental.classRegex": [
    ["tailwind\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["Tailwindcss::Style\\.new\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
  ],
  "files.associations": {
    "*.css": "tailwindcss"
  }
}
```

### RubyMine Configuration

1. Install Tailwind CSS plugin
2. Configure file watchers:
   - Program: `bundle`
   - Arguments: `exec rake tailwindcss:compile`
   - Output paths: `$ProjectFileDir$/tmp/tailwindcss`

## Troubleshooting

### Classes Not Updating

1. Clear the cache:
```bash
rm -rf tmp/tailwindcss/*
bundle exec rake tailwindcss:compile
```

2. Check file watcher:
```bash
# Verify watcher is running
ps aux | grep tailwindcss

# Check for file system limits
ulimit -n  # Should be > 1024
```

3. Verify content paths:
```ruby
# rails console
puts Tailwindcss.configuration.content
```

### Slow Compilation

- Reduce content paths to only necessary files
- Enable caching in development
- Use incremental compilation
- Consider using `--watch` with `--poll` for VMs

### Memory Issues

```ruby
# Limit parser memory
config.compiler.max_memory = 512  # MB

# Use incremental builds
config.compiler.incremental = true
```

## Best Practices

1. **Use specific content paths** - Don't scan unnecessary files
2. **Enable source maps** - For easier debugging
3. **Keep console open** - Watch for compilation errors
4. **Test incrementally** - Verify styles as you build
5. **Document patterns** - Keep a styleguide page