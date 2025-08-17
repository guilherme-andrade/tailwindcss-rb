# Tailwindcss-rb

This is a ruby gem that adds a ruby-like library and compiler for tailwindcss. It's goal is to serve as a an atomic set of functions
that help you build your own UI framework in ruby.

Add this line to your application's Gemfile:

```ruby
gem 'tailwindcss'
```

Then execute:

```bash
bundle install
```

And run the installer:

```bash
bundle exec rake tailwindcss:install
```


## Basic Usage

At its core of the gem, is the `Style` class. This class is used to generate tailwindcss classes in a ruby-like way.

```ruby
Tailwindcss::Style.new(bg: :red).to_s
# => "bg-red-500"
```

Or using the `tailwind` helper.

```ruby
include Tailwindcss::Helpers

tailwind(bg: :red, text: :white)
# => "bg-red-500 text-white"
```

## Configuration

You can configure the gem by creating an initializer file in your rails app.

```ruby
# config/initializers/tailwindcss.rb

Tailwindcss.configure do |config|
  config.package_json_path = "./package.json"
  config.config_file_path = "./tailwind.config.js"
  config.compiler.output_path = "./public/assets/styles.css"
  config.compiler.compile_classes_dir = "./tmp/tailwindcss"
  config.content = []
  config.prefix = ""
  config.watch_content = false
  config.breakpoints = %i[xs sm md lg xl 2xl]
  config.pseudo_selectors = %i[hover focus active visited disabled first last first_of_type last_of_type odd even group_hover]
  config.pseudo_elements = %i[before after file first_letter first_line selection backdrop marker]
  config.logger = Logger.new(STDOUT)
  config.theme.color_scheme = {
    primary: :red,
    secondary: :blue,
    tertiary: :green
  }
  # other theme configurations
end
```

## Compiling your styles

You can compile your styles by running the following command.

```bash
bundle exec rake tailwindcss:compile
```

Or by starting a process that watches for changes.

```bash
bundle exec rake tailwindcss:compile:watch
```

### How it works

The `tailwindcss-rb` compiler parses through the files in the `config.content`, and attempts to stactically extract the arguments you pass to the `tailwind` helper method. It then generates the tailwindcss classes and writes them to the `config.compiler.output_path`.

This file is then used by the tailwindcss compiler to generate the final css file.

##### Example

Given that you configured the gem as follows:

```ruby
Tailwindcss.configure do |config|
  config.content = [
    "app/views/**/*.html.erb",
  ]
end
```

And that you're writing the following code in your view file:

```erb
# app/views/layouts/application.html.erb

<div class="<%= tailwind(bg: :red, text: :white) %>">
  Hello World
</div>
```

The compiler will generate the following "classes" file.

```
bg-red-500 text-white
```

And these classes will be added by the tailwind compiler to the final css file.


### Recommended use in development

When making changes related to your css, it is recommended that you set up a process that watches for changes and compiles the css file.

You can either do this by running the following command in a separate terminal window:

```bash
bundle exec rake tailwindcss:compile:watch
```

Or by adding the following line to your `Procfile.dev` file when using foreman.

```yaml
tailwindcss: bundle exec rake tailwindcss:compile:watch
```

### Recommended use in production

When deploying to production, it is recommended that you compile the css file before deploying.

You can do this by running the following command:

```bash
bundle exec rake tailwindcss:compile
```

### Heroku

If you're deploying to heroku, you can add the following line to your `Procfile` file to make sure the css file is compiled before deploying.

```yaml
release: bundle exec rake tailwindcss:compile
```

### Uploading to a CDN

If you're uploading your assets to a CDN, you can add the following line to your `Rakefile` to make sure the css file is compiled before uploading.

```ruby
task "assets:precompile" => "tailwindcss:compile"
```

And make sure that your configuration is set up to use the correct file url in helpers.

```ruby
Tailwindcss.configure do |config|
  config.tailwind_css_file_path = proc { "https://cdn.example.com/assets/styles.css" }
end
```
> We're currently working on a fix to make this easier to configure and support fingerprinting.

## Advanced Usage

### Using Modifiers

Any key that starts with an underscore is considered a modifier. Modifiers are used to add pseudo classes and elements to the class.

```ruby
tailwind(bg: :red, text: :white, _hover: { bg: :blue })
# => "bg-red-500 text-white hover:bg-blue-500"

tailwind(bg: :red, text: :white, _hover: { bg: :blue }, _before: { content: '[""]' })
# => "bg-red-500 text-white hover:bg-blue-500 before:content-[\"\"]"
```

### Dark Mode Support

Use the `dark()` helper for cleaner dark mode styling:

```ruby
# Basic dark mode
tailwind(bg: :white, text: :black, **dark(bg: :gray, text: :white))
# => "bg-white text-black dark:bg-gray-500 dark:text-white"

# Nested modifiers with dark mode
tailwind(
  bg: :white,
  **dark(
    bg: :gray,
    _hover: { bg: :blue }
  )
)
# => "bg-white dark:bg-gray-500 dark:hover:bg-blue-500"
```

### Responsive Design

Use the `at()` helper for responsive breakpoints:

```ruby
# Responsive padding
tailwind(p: 2, **at(:md, p: 4), **at(:lg, p: 6))
# => "p-2 md:p-4 lg:p-6"

# Combine responsive with dark mode
tailwind(**at(:lg, **dark(bg: :black)))
# => "lg:dark:bg-black"
```

### Style Composition

The `Style` class supports powerful composition patterns:

```ruby
# Merge styles
base_button = Tailwindcss::Style.new(px: 4, py: 2, rounded: :md)
primary_button = base_button.merge(bg: :blue, text: :white)

# Use + operator
large_button = primary_button + Tailwindcss::Style.new(px: 6, py: 3)

# Override specific attributes
modified = primary_button.with(bg: :green)

# Remove attributes
minimal = primary_button.except(:rounded)

# Check if empty
style = Tailwindcss::Style.new
style.empty? # => true
```

### Component Pattern Example

```ruby
class ButtonComponent
  include Tailwindcss::Helpers

  def self.style(variant: :primary, size: :md, **custom)
    base = Tailwindcss::Style.new(
      px: 4, py: 2, 
      rounded: :md, 
      font: :medium
    )
    
    variants = {
      primary: { bg: :blue, text: :white },
      secondary: { bg: :gray, text: :black }
    }
    
    sizes = {
      sm: { px: 3, py: 1, text: :sm },
      md: { px: 4, py: 2, text: :base },
      lg: { px: 6, py: 3, text: :lg }
    }
    
    base.merge(variants[variant])
        .merge(sizes[size])
        .merge(custom)
  end
end

# Usage
button = ButtonComponent.style(variant: :primary, size: :lg, shadow: :xl)
```

### Using arbitrary values

When using arbitrary values, make sure to wrap the value in `[]` to use the value as is.

```ruby
tailwind(bg: "[url('image.png')]")
# => "bg-[url('image.png')]"
```

### Using color scheme values

You can use the color scheme values by using the `color_scheme_token` method.

```ruby
Tailwindcss.configure do |config|
  config.theme.color_scheme = {
    primary: :red,
    secondary: :blue,
    tertiary: :green
  }
end

tailwind(bg: color_scheme_token(:primary))
# => "bg-red-500"
```

Optionally, you can specify a shade.

```ruby
tailwind(bg: color_scheme_token(:primary, 100))
# => "bg-red-100"
```

## Building Reusable Components

### Creating a Card Component

```ruby
class CardComponent
  include Tailwindcss::Helpers

  attr_reader :style

  def initialize(elevated: false, dark_mode: true)
    @style = base_style
    @style = @style.merge(elevation_style) if elevated
    @style = @style.merge(dark_mode_style) if dark_mode
  end

  private

  def base_style
    Tailwindcss::Style.new(
      bg: :white,
      rounded: :lg,
      p: 6,
      border: true,
      border_gray: 200
    )
  end

  def elevation_style
    { shadow: :xl, border: false }
  end

  def dark_mode_style
    dark(
      bg: :gray_800,
      border_gray: 700,
      text: :gray_100
    )
  end
end

# Usage in views
card = CardComponent.new(elevated: true)
content_tag :div, class: card.style.to_s do
  # content
end
```

### Creating a Form Input Component

```ruby
class FormInputComponent
  include Tailwindcss::Helpers

  STATES = {
    default: { border_gray: 300, focus: { border_blue: 500, ring_blue: 500 } },
    error: { border_red: 500, focus: { border_red: 500, ring_red: 500 } },
    success: { border_green: 500, focus: { border_green: 500, ring_green: 500 } }
  }.freeze

  def self.style(state: :default, size: :md)
    base = Tailwindcss::Style.new(
      block: true,
      w: :full,
      rounded: :md,
      border: true,
      shadow: :sm,
      _focus: { ring: 2, ring_offset: 2, outline: :none }
    )

    sizes = {
      sm: { px: 3, py: 1.5, text: :sm },
      md: { px: 4, py: 2, text: :base },
      lg: { px: 4, py: 3, text: :lg }
    }

    base.merge(STATES[state])
        .merge(sizes[size])
        .merge(dark(
          bg: :gray_700,
          border_gray: 600,
          text: :white
        ))
  end
end

# Usage
input_class = FormInputComponent.style(state: :error, size: :lg).to_s
```

### Alert Component with Variants

```ruby
class AlertComponent
  include Tailwindcss::Helpers

  def initialize(type: :info, dismissible: false)
    @type = type
    @dismissible = dismissible
  end

  def style
    base_style
      .merge(type_styles[@type])
      .merge(dark_styles)
      .tap { |s| s.merge!(dismissible_styles) if @dismissible }
  end

  private

  def base_style
    Tailwindcss::Style.new(
      p: 4,
      rounded: :lg,
      border_l: 4,
      mb: 4
    )
  end

  def type_styles
    {
      info: { bg: :blue_50, border_blue: 400, text: :blue_800 },
      success: { bg: :green_50, border_green: 400, text: :green_800 },
      warning: { bg: :yellow_50, border_yellow: 400, text: :yellow_800 },
      error: { bg: :red_50, border_red: 400, text: :red_800 }
    }
  end

  def dark_styles
    dark(bg: :gray_800, text: :gray_100)
  end

  def dismissible_styles
    { relative: true, pr: 12 }
  end
end
```

## Tips and Best Practices

### 1. Use Composition Over Repetition

```ruby
# Good - Reusable styles
button_base = Tailwindcss::Style.new(px: 4, py: 2, rounded: :md)
primary = button_base.merge(bg: :blue, text: :white)
secondary = button_base.merge(bg: :gray, text: :black)

# Avoid - Repetitive
primary = tailwind(px: 4, py: 2, rounded: :md, bg: :blue, text: :white)
secondary = tailwind(px: 4, py: 2, rounded: :md, bg: :gray, text: :black)
```

### 2. Organize Responsive Styles

```ruby
# Clean responsive progression
tailwind(
  text: :sm,                    # Mobile first
  **at(:md, text: :base),       # Tablet
  **at(:lg, text: :lg),         # Desktop
  **at(:xl, text: :xl)          # Large screens
)
```

### 3. Dark Mode Best Practices

```ruby
# Group dark mode styles together
tailwind(
  # Light mode
  bg: :white,
  text: :gray_900,
  border: :gray_200,
  
  # Dark mode as a unit
  **dark(
    bg: :gray_900,
    text: :gray_100,
    border: :gray_700
  )
)
```

### 4. Performance Tips

- Keep your `config.content` paths specific to files that actually use Tailwind
- The library caches parsed files automatically for faster subsequent builds
- Use watch mode during development for instant feedback

## Troubleshooting

### Classes not appearing in CSS

1. Ensure your file is in the configured content paths
2. Check that you're using the `tailwind()` helper (not plain strings)
3. Clear the cache if needed: `rm -rf tmp/tailwindcss/*.json`

### Compilation is slow

- Reduce the number of files in `config.content`
- Ensure the cache directory is writable
- Use watch mode to avoid full recompilations

### Dark mode not working

- Verify your Tailwind config has dark mode enabled
- Use the `dark()` helper for proper class generation
- Check your HTML has the `dark` class or uses media queries

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/guilherme-andrade/tailwindcss-rb.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

