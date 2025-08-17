# Helpers API

The Helpers module provides convenient methods for generating Tailwind classes in your Ruby code.

## Module Methods

### tailwind

The main helper method for generating Tailwind classes.

```ruby
include Tailwindcss::Helpers

tailwind(bg: :blue, text: :white, p: 4)
# => "bg-blue-500 text-white p-4"
```

**Parameters:**
- `**attributes` - Hash of Tailwind properties and values

**Returns:** `String` - Space-separated Tailwind classes

### dark

Creates dark mode variants of styles.

```ruby
dark(bg: :gray_900, text: :white)
# => { _dark: { bg: :gray_900, text: :white } }
```

**Parameters:**
- `**attributes` - Hash of dark mode styles

**Returns:** `Hash` - Properly structured dark mode modifiers

**Usage:**
```ruby
tailwind(
  bg: :white,
  **dark(bg: :gray_900)
)
# => "bg-white dark:bg-gray-900"
```

### at

Applies styles at specific responsive breakpoints.

```ruby
at(:md, p: 4, text: :lg)
# => { _md: { p: 4, text: :lg } }
```

**Parameters:**
- `breakpoint` - Symbol (`:sm`, `:md`, `:lg`, `:xl`, `:2xl`)
- `**attributes` - Hash of styles to apply at breakpoint

**Returns:** `Hash` - Properly structured responsive modifiers

**Usage:**
```ruby
tailwind(
  p: 2,
  **at(:md, p: 4),
  **at(:lg, p: 6)
)
# => "p-2 md:p-4 lg:p-6"
```

### color_scheme_token

References colors from your configured color scheme.

```ruby
color_scheme_token(:primary)
# => :blue_500 (if primary is configured as :blue)

color_scheme_token(:primary, 600)
# => :blue_600
```

**Parameters:**
- `name` - Symbol name of the color in your scheme
- `shade` - Optional shade number (100-900)

**Returns:** `Symbol` - Color token for use in tailwind

**Configuration:**
```ruby
Tailwindcss.configure do |config|
  config.theme.color_scheme = {
    primary: :blue,
    secondary: :green,
    danger: :red
  }
end
```

## Helper Patterns

### Combining Helpers

```ruby
# Dark mode with responsive
tailwind(
  bg: :white,
  **dark(bg: :gray_900),
  **at(:lg, **dark(bg: :gray_800))
)
```

### Nested Modifiers

```ruby
# Hover state in dark mode
tailwind(
  **dark(
    bg: :gray_900,
    _hover: { bg: :gray_800 }
  )
)
```

## Advanced Usage

### Custom Helper Methods

Create your own helper methods:

```ruby
module CustomHelpers
  include Tailwindcss::Helpers
  
  def brand_button(**options)
    tailwind(
      px: 4,
      py: 2,
      bg: color_scheme_token(:primary),
      text: :white,
      rounded: :md,
      **options
    )
  end
  
  def responsive_text(sm: :sm, md: :base, lg: :lg)
    tailwind(
      text: sm,
      **at(:md, text: md),
      **at(:lg, text: lg)
    )
  end
  
  def card_style(elevated: false)
    base = {
      bg: :white,
      rounded: :lg,
      p: 6
    }
    
    elevated_props = elevated ? { shadow: :xl } : { shadow: :md }
    
    tailwind(base.merge(elevated_props))
  end
end
```

### Conditional Helpers

```ruby
module ConditionalHelpers
  include Tailwindcss::Helpers
  
  def maybe_dark(condition, **styles)
    condition ? dark(**styles) : {}
  end
  
  def responsive_if(condition, breakpoint, **styles)
    condition ? at(breakpoint, **styles) : {}
  end
  
  def theme_aware(**light_styles)
    dark_styles = light_styles.transform_values do |value|
      case value
      when :white then :gray_900
      when :black then :white
      when :gray_100 then :gray_800
      else value
      end
    end
    
    tailwind(
      **light_styles,
      **dark(dark_styles)
    )
  end
end
```

## Component Integration

### Rails View Helpers

```ruby
module ApplicationHelper
  include Tailwindcss::Helpers
  
  def button_classes(variant: :primary, size: :md, **custom)
    base = {
      inline_flex: true,
      items: :center,
      rounded: :md,
      font: :medium
    }
    
    variants = {
      primary: { bg: :blue, text: :white },
      secondary: { bg: :gray_200, text: :gray_900 }
    }
    
    sizes = {
      sm: { px: 3, py: 1.5, text: :sm },
      md: { px: 4, py: 2, text: :base },
      lg: { px: 6, py: 3, text: :lg }
    }
    
    tailwind(
      **base,
      **variants[variant],
      **sizes[size],
      **custom
    )
  end
  
  def card_classes(**options)
    tailwind(
      bg: :white,
      rounded: :lg,
      shadow: :md,
      p: 6,
      **dark(bg: :gray_800),
      **options
    )
  end
end
```

### ViewComponent Integration

```ruby
class ButtonComponent < ViewComponent::Base
  include Tailwindcss::Helpers
  
  def initialize(variant: :primary, size: :md, **options)
    @variant = variant
    @size = size
    @options = options
  end
  
  def classes
    tailwind(
      **base_classes,
      **variant_classes,
      **size_classes,
      **@options
    )
  end
  
  private
  
  def base_classes
    {
      inline_flex: true,
      items: :center,
      justify: :center,
      rounded: :md,
      font: :medium,
      transition: :colors
    }
  end
  
  def variant_classes
    variants[@variant] || variants[:primary]
  end
  
  def size_classes
    sizes[@size] || sizes[:md]
  end
  
  def variants
    {
      primary: { bg: :blue, text: :white },
      secondary: { bg: :gray_200, text: :gray_900 },
      danger: { bg: :red, text: :white }
    }
  end
  
  def sizes
    {
      sm: { px: 3, py: 1.5, text: :sm },
      md: { px: 4, py: 2, text: :base },
      lg: { px: 6, py: 3, text: :lg }
    }
  end
end
```

## Testing Helpers

```ruby
RSpec.describe Tailwindcss::Helpers do
  include described_class
  
  describe '#tailwind' do
    it 'generates correct classes' do
      result = tailwind(bg: :blue, text: :white)
      expect(result).to eq('bg-blue-500 text-white')
    end
  end
  
  describe '#dark' do
    it 'creates dark mode variants' do
      result = tailwind(**dark(bg: :gray_900))
      expect(result).to include('dark:bg-gray-900')
    end
  end
  
  describe '#at' do
    it 'creates responsive variants' do
      result = tailwind(**at(:md, p: 4))
      expect(result).to include('md:p-4')
    end
  end
  
  describe '#color_scheme_token' do
    before do
      Tailwindcss.configure do |config|
        config.theme.color_scheme = {
          primary: :blue
        }
      end
    end
    
    it 'resolves color scheme tokens' do
      result = color_scheme_token(:primary)
      expect(result).to eq(:blue_500)
    end
  end
end
```

## Performance Tips

1. **Memoize repeated calls**: Cache generated classes for static content
2. **Use constants**: Define frequently used style combinations
3. **Avoid runtime computation**: Pre-compute styles when possible

```ruby
class OptimizedComponent
  include Tailwindcss::Helpers
  
  BUTTON_STYLES = {
    primary: 'bg-blue-500 text-white px-4 py-2',
    secondary: 'bg-gray-200 text-gray-900 px-4 py-2'
  }.freeze
  
  def button_class(variant)
    BUTTON_STYLES[variant] || tailwind(default_button_props)
  end
  
  private
  
  def default_button_props
    @default_button_props ||= {
      px: 4,
      py: 2,
      rounded: :md
    }
  end
end
```