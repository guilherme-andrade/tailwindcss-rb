# Installation

## Adding to Your Project

### Step 1: Add to Gemfile

Add tailwindcss-rb to your application's Gemfile:

```ruby
gem 'tailwindcss-rb'
```

### Step 2: Install Dependencies

Run bundle to install the gem:

```bash
bundle install
```

### Step 3: Run the Installer

The installer will set up the necessary configuration files:

```bash
bundle exec rake tailwindcss:install
```

This command will:
- Create a Tailwind configuration file (`tailwind.config.js`)
- Set up the compiler output directory
- Configure content paths for class extraction
- Create an initializer for Rails applications

## Manual Installation

If you prefer to set up manually or need custom configuration:

### 1. Create Configuration File

Create `config/initializers/tailwindcss.rb`:

```ruby
Tailwindcss.configure do |config|
  config.content = [
    "app/views/**/*.html.erb",
    "app/helpers/**/*.rb",
    "app/components/**/*.rb"
  ]
  
  config.compiler.output_path = "./app/assets/stylesheets/tailwind.css"
  config.compiler.compile_classes_dir = "./tmp/tailwindcss"
end
```

### 2. Set Up Tailwind Config

Create `tailwind.config.js` in your project root:

```javascript
module.exports = {
  content: [
    './tmp/tailwindcss/**/*.classes'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

### 3. Add Compilation Task

Add to your deployment or build process:

```bash
bundle exec rake tailwindcss:compile
```

## Verifying Installation

To verify everything is working:

1. Create a test view:

```erb
<div class="<%= tailwind(bg: :green, text: :white, p: 4) %>">
  Installation successful!
</div>
```

2. Compile the styles:

```bash
bundle exec rake tailwindcss:compile
```

3. Check that the CSS file was generated at your configured output path

## Next Steps

- [Configure](./configuration) your tailwindcss-rb setup
- Learn [Basic Usage](./basic-usage) patterns
- Set up [Development](./development) workflow