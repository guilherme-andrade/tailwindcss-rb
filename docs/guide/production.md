# Production Deployment

Configure and optimize tailwindcss-rb for production environments.

## Production Build

### Basic Compilation

Compile your styles for production:

```bash
bundle exec rake tailwindcss:compile RAILS_ENV=production
```

This will:
- Scan all configured content paths
- Extract and compile all used classes
- Minify the output CSS
- Generate production-optimized styles

### Build Task Integration

Add to your deployment process:

```ruby
# lib/tasks/deploy.rake
namespace :deploy do
  desc "Prepare assets for production"
  task :assets => :environment do
    Rake::Task["assets:precompile"].invoke
    Rake::Task["tailwindcss:compile"].invoke
  end
end
```

## Production Configuration

### Optimized Settings

```ruby
# config/initializers/tailwindcss.rb

if Rails.env.production?
  Tailwindcss.configure do |config|
    # Disable file watching
    config.watch_content = false
    
    # Minimal logging
    config.logger = Rails.logger
    config.logger.level = Logger::ERROR
    
    # Enable all optimizations
    config.compiler.minify = true
    config.compiler.remove_unused = true
    config.compiler.optimize = true
    
    # Production output path
    config.compiler.output_path = Rails.root.join(
      "public", "assets", "tailwind-#{assets_version}.css"
    )
    
    # CDN configuration
    config.tailwind_css_file_path = proc {
      "#{ENV['CDN_HOST']}/assets/tailwind-#{assets_version}.css"
    }
  end
end

def assets_version
  @assets_version ||= Digest::MD5.hexdigest(
    File.read(Rails.root.join("config", "tailwind.config.js"))
  )[0..7]
end
```

## Asset Pipeline Integration

### Sprockets

```ruby
# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w[tailwind.css]

# app/assets/config/manifest.js
//= link tailwind.css
```

```ruby
# lib/tasks/tailwindcss.rake
Rake::Task["assets:precompile"].enhance do
  Rake::Task["tailwindcss:compile"].invoke
end
```

### Webpacker/Shakapacker

```javascript
// app/javascript/packs/application.js
import '../stylesheets/tailwind.css'
```

```yaml
# config/webpacker.yml
production:
  compile: true
  extract_css: true
  cache_manifest: true
```

## CDN Deployment

### AWS CloudFront

```ruby
# config/initializers/tailwindcss.rb
config.tailwind_css_file_path = proc {
  if Rails.env.production?
    "https://d1234567890.cloudfront.net/assets/tailwind-#{digest}.css"
  else
    "/assets/tailwind.css"
  end
}
```

### Upload to S3

```ruby
# lib/tasks/cdn.rake
namespace :cdn do
  desc "Upload compiled CSS to S3"
  task :upload => :environment do
    require 'aws-sdk-s3'
    
    s3 = Aws::S3::Client.new
    file_path = Tailwindcss.configuration.compiler.output_path
    key = "assets/tailwind-#{digest}.css"
    
    File.open(file_path, 'rb') do |file|
      s3.put_object(
        bucket: ENV['S3_BUCKET'],
        key: key,
        body: file,
        content_type: 'text/css',
        cache_control: 'public, max-age=31536000'
      )
    end
    
    puts "Uploaded to #{key}"
  end
end
```

### Fingerprinting

```ruby
# app/helpers/application_helper.rb
def tailwind_stylesheet_link_tag
  if Rails.env.production?
    path = compute_tailwind_asset_path
    stylesheet_link_tag path, skip_pipeline: true
  else
    stylesheet_link_tag 'tailwind'
  end
end

private

def compute_tailwind_asset_path
  Rails.cache.fetch("tailwind_asset_path", expires_in: 1.day) do
    "/assets/tailwind-#{compute_digest}.css"
  end
end

def compute_digest
  Digest::MD5.hexdigest(
    Dir["app/**/*.{erb,rb}"].map { |f| File.read(f) }.join
  )[0..7]
end
```

## Platform-Specific Deployment

### Heroku

```ruby
# Procfile
release: bundle exec rake tailwindcss:compile
web: bundle exec puma -C config/puma.rb
```

```json
// package.json
{
  "scripts": {
    "build": "npm run build:css",
    "build:css": "bundle exec rake tailwindcss:compile"
  }
}
```

Add buildpacks:
```bash
heroku buildpacks:add heroku/nodejs
heroku buildpacks:add heroku/ruby
```

### Docker

```dockerfile
# Dockerfile
FROM ruby:3.2-slim AS builder

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  nodejs \
  npm

WORKDIR /app

COPY Gemfile* ./
RUN bundle config set without 'development test'
RUN bundle install --jobs=4

COPY package* ./
RUN npm ci --production

COPY . .

# Compile assets and Tailwind CSS
RUN bundle exec rake assets:precompile
RUN bundle exec rake tailwindcss:compile

# Production image
FROM ruby:3.2-slim

RUN apt-get update -qq && apt-get install -y \
  postgresql-client \
  nodejs

WORKDIR /app

COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle /usr/local/bundle

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

### Kubernetes

```yaml
# k8s/deployment.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: compile-assets
spec:
  template:
    spec:
      containers:
      - name: compiler
        image: myapp:latest
        command: ["bundle", "exec", "rake", "tailwindcss:compile"]
        volumeMounts:
        - name: assets
          mountPath: /app/public/assets
      volumes:
      - name: assets
        persistentVolumeClaim:
          claimName: assets-pvc
```

## Caching Strategies

### Rails Cache

```ruby
# app/models/style_cache.rb
class StyleCache
  def self.fetch(key, &block)
    Rails.cache.fetch(
      "tailwind/#{key}",
      expires_in: 1.week,
      race_condition_ttl: 10.seconds,
      &block
    )
  end
  
  def self.clear
    Rails.cache.delete_matched("tailwind/*")
  end
end
```

### HTTP Caching

```ruby
# app/controllers/assets_controller.rb
class AssetsController < ApplicationController
  def tailwind
    expires_in 1.year, public: true
    
    if stale?(etag: tailwind_etag, last_modified: tailwind_mtime)
      send_file tailwind_path,
                type: 'text/css',
                disposition: 'inline'
    end
  end
  
  private
  
  def tailwind_etag
    Digest::MD5.hexdigest(File.read(tailwind_path))
  end
  
  def tailwind_mtime
    File.mtime(tailwind_path)
  end
  
  def tailwind_path
    Rails.root.join('public', 'assets', 'tailwind.css')
  end
end
```

## Performance Optimization

### Minification

```ruby
config.compiler.minify = true
config.compiler.remove_comments = true
config.compiler.remove_unused = true
```

### Compression

```nginx
# nginx.conf
location ~* \.(css)$ {
  gzip_static on;
  expires 1y;
  add_header Cache-Control "public, immutable";
}
```

```ruby
# Rake task to pre-compress
task :compress_assets do
  Dir["public/assets/*.css"].each do |file|
    `gzip -9 -k #{file}`
    `brotli -9 -k #{file}`
  end
end
```

### Content Delivery

```ruby
# config/environments/production.rb
config.action_controller.asset_host = ENV['CDN_HOST']

# Enable serving of images, stylesheets, and JavaScripts from an asset server
config.asset_host = "https://cdn.example.com"
```

## Monitoring

### Health Checks

```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def tailwind
    if File.exist?(tailwind_path) && 
       File.size(tailwind_path) > 1000
      render json: { status: 'ok', size: File.size(tailwind_path) }
    else
      render json: { status: 'error' }, status: :service_unavailable
    end
  end
  
  private
  
  def tailwind_path
    Tailwindcss.configuration.compiler.output_path
  end
end
```

### Metrics

```ruby
# config/initializers/tailwindcss_metrics.rb
ActiveSupport::Notifications.subscribe('compile.tailwindcss') do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  
  StatsD.timing('tailwindcss.compile_time', event.duration)
  StatsD.gauge('tailwindcss.file_size', File.size(event.payload[:output_path]))
  StatsD.increment('tailwindcss.compilations')
end
```

## Rollback Strategy

```ruby
# lib/tasks/tailwind_backup.rake
namespace :tailwindcss do
  desc "Backup current CSS before deployment"
  task :backup => :environment do
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    source = Tailwindcss.configuration.compiler.output_path
    backup = "#{source}.#{timestamp}.backup"
    
    FileUtils.cp(source, backup) if File.exist?(source)
    
    # Keep only last 5 backups
    backups = Dir["#{source}.*.backup"].sort
    backups[0...-5].each { |f| File.delete(f) }
  end
  
  desc "Restore previous CSS version"
  task :restore => :environment do
    source = Tailwindcss.configuration.compiler.output_path
    backup = Dir["#{source}.*.backup"].sort.last
    
    if backup
      FileUtils.cp(backup, source)
      puts "Restored from #{backup}"
    else
      puts "No backup found"
    end
  end
end
```

## Troubleshooting Production Issues

### Missing Classes

```bash
# Verify compilation
RAILS_ENV=production bundle exec rake tailwindcss:compile --trace

# Check output
cat public/assets/tailwind*.css | grep "bg-blue-500"
```

### Asset Not Found

```ruby
# Verify paths
rails console -e production
> Tailwindcss.configuration.compiler.output_path
> Tailwindcss.configuration.tailwind_css_file_path
```

### Performance Issues

- Enable CDN for global distribution
- Use HTTP/2 push for critical CSS
- Implement service workers for offline caching
- Consider splitting CSS for above/below fold