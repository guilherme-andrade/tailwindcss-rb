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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/guilherme-andrade/tailwindcss-rb.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

