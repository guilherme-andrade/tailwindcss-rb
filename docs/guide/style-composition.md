# Style Composition

Style composition is a powerful pattern in tailwindcss-rb that allows you to build complex, reusable styles from simpler building blocks.

## The Style Class

The `Tailwindcss::Style` class provides methods for composing styles:

```ruby
base = Tailwindcss::Style.new(p: 4, rounded: :md)
extended = base.merge(bg: :blue, text: :white)
```

## Composition Methods

### merge

Creates a new style by combining with another:

```ruby
button = Tailwindcss::Style.new(px: 4, py: 2)
primary = button.merge(bg: :blue, text: :white)
# primary has: px: 4, py: 2, bg: :blue, text: :white
```

### with

Replaces specific properties:

```ruby
original = Tailwindcss::Style.new(bg: :blue, text: :white, p: 4)
modified = original.with(bg: :red)
# modified has: bg: :red, text: :white, p: 4
```

### except

Removes specific properties:

```ruby
full = Tailwindcss::Style.new(bg: :blue, text: :white, p: 4, border: true)
minimal = full.except(:border, :bg)
# minimal has: text: :white, p: 4
```

### + operator

Alias for merge:

```ruby
base = Tailwindcss::Style.new(p: 4)
enhanced = base + Tailwindcss::Style.new(bg: :blue)
```

## Composition Patterns

### Layered Styles

```ruby
class LayeredButton
  include Tailwindcss::Helpers
  
  def self.base_style
    Tailwindcss::Style.new(
      inline_flex: true,
      items: :center,
      justify: :center,
      font: :medium,
      rounded: :md,
      transition: :colors
    )
  end
  
  def self.size_style(size)
    sizes = {
      sm: { px: 3, py: 1.5, text: :sm },
      md: { px: 4, py: 2, text: :base },
      lg: { px: 6, py: 3, text: :lg }
    }
    Tailwindcss::Style.new(sizes[size] || sizes[:md])
  end
  
  def self.variant_style(variant)
    variants = {
      primary: { 
        bg: :blue, 
        text: :white,
        _hover: { bg: :blue_600 }
      },
      secondary: { 
        bg: :gray_200, 
        text: :gray_900,
        _hover: { bg: :gray_300 }
      },
      danger: { 
        bg: :red, 
        text: :white,
        _hover: { bg: :red_600 }
      }
    }
    Tailwindcss::Style.new(variants[variant] || variants[:primary])
  end
  
  def self.build(size: :md, variant: :primary, **custom)
    base_style
      .merge(size_style(size))
      .merge(variant_style(variant))
      .merge(custom)
  end
end

# Usage
button = LayeredButton.build(size: :lg, variant: :danger, shadow: :lg)
```

### Theme System

```ruby
class ThemeProvider
  include Tailwindcss::Helpers
  
  def self.theme
    @theme ||= {
      colors: {
        primary: :blue,
        secondary: :green,
        danger: :red,
        warning: :yellow
      },
      spacing: {
        xs: 1,
        sm: 2,
        md: 4,
        lg: 6,
        xl: 8
      },
      typography: {
        heading: { font: :bold, tracking: :tight },
        body: { font: :normal, leading: :relaxed },
        caption: { text: :sm, text_gray: 600 }
      }
    }
  end
  
  def self.compose(*styles)
    styles.reduce(Tailwindcss::Style.new) { |acc, style| 
      acc.merge(resolve_theme_tokens(style))
    }
  end
  
  private
  
  def self.resolve_theme_tokens(style)
    # Transform theme tokens to actual values
    style
  end
end
```

### Component Composition

```ruby
class Card
  include Tailwindcss::Helpers
  
  def self.base
    Tailwindcss::Style.new(
      bg: :white,
      rounded: :lg,
      shadow: :md
    )
  end
  
  def self.padded(size = :md)
    padding = { sm: 4, md: 6, lg: 8 }
    base.merge(p: padding[size])
  end
  
  def self.bordered
    base.merge(
      border: true,
      border_gray: 200,
      shadow: :none
    )
  end
  
  def self.elevated
    base.merge(
      shadow: :xl,
      _hover: { shadow: "2xl" }
    )
  end
  
  def self.dark_mode
    base.merge(
      **dark(
        bg: :gray_800,
        border_gray: 700
      )
    )
  end
end

# Usage
simple_card = Card.base
padded_card = Card.padded(:lg)
fancy_card = Card.elevated.merge(Card.dark_mode)
```

### Mixin Pattern

```ruby
module StyleMixins
  module Hoverable
    def hoverable(scale: 105, shadow: :lg)
      merge(
        transition: :all,
        cursor: :pointer,
        _hover: {
          scale: scale,
          shadow: shadow
        }
      )
    end
  end
  
  module Focusable
    def focusable(ring_color: :blue)
      merge(
        _focus: {
          outline: :none,
          ring: 2,
          "ring_#{ring_color}": 500,
          ring_offset: 2
        }
      )
    end
  end
  
  module Responsive
    def responsive_padding(base: 2, md: 4, lg: 6)
      merge(
        p: base,
        **at(:md, p: md),
        **at(:lg, p: lg)
      )
    end
  end
end

class EnhancedStyle < Tailwindcss::Style
  include StyleMixins::Hoverable
  include StyleMixins::Focusable
  include StyleMixins::Responsive
end

# Usage
style = EnhancedStyle.new(bg: :white)
  .hoverable
  .focusable(ring_color: :green)
  .responsive_padding
```

## Advanced Composition

### Conditional Composition

```ruby
class ConditionalStyle
  include Tailwindcss::Helpers
  
  def self.build(options = {})
    style = Tailwindcss::Style.new(base_styles)
    
    style = style.merge(elevated_styles) if options[:elevated]
    style = style.merge(bordered_styles) if options[:bordered]
    style = style.merge(dark_styles) if options[:dark_mode]
    style = style.merge(options[:custom]) if options[:custom]
    
    style
  end
  
  private
  
  def self.base_styles
    { p: 4, rounded: :md }
  end
  
  def self.elevated_styles
    { shadow: :xl, _hover: { shadow: "2xl" } }
  end
  
  def self.bordered_styles
    { border: true, border_gray: 300 }
  end
  
  def self.dark_styles
    dark(bg: :gray_800, text: :white)
  end
end
```

### Style Factory

```ruby
class StyleFactory
  include Tailwindcss::Helpers
  
  def initialize
    @styles = {}
  end
  
  def register(name, style)
    @styles[name] = style
    self
  end
  
  def build(*names, **overrides)
    names.reduce(Tailwindcss::Style.new) do |acc, name|
      acc.merge(@styles[name] || {})
    end.merge(overrides)
  end
end

# Setup
factory = StyleFactory.new
  .register(:card, { bg: :white, rounded: :lg, shadow: :md })
  .register(:interactive, { cursor: :pointer, _hover: { shadow: :lg } })
  .register(:padded, { p: 6 })

# Usage
style = factory.build(:card, :interactive, :padded, bg: :blue_50)
```

### Inheritance Pattern

```ruby
class BaseComponent
  include Tailwindcss::Helpers
  
  def base_style
    Tailwindcss::Style.new(
      rounded: :md,
      transition: :all
    )
  end
  
  def style
    base_style
  end
end

class Button < BaseComponent
  def button_style
    Tailwindcss::Style.new(
      px: 4,
      py: 2,
      font: :medium
    )
  end
  
  def style
    super.merge(button_style)
  end
end

class PrimaryButton < Button
  def primary_style
    Tailwindcss::Style.new(
      bg: :blue,
      text: :white,
      _hover: { bg: :blue_600 }
    )
  end
  
  def style
    super.merge(primary_style)
  end
end
```

## Performance Optimization

### Memoization

```ruby
class OptimizedComponent
  include Tailwindcss::Helpers
  
  def style
    @style ||= compute_style
  end
  
  private
  
  def compute_style
    base
      .merge(variant_styles)
      .merge(size_styles)
      .merge(state_styles)
  end
  
  def base
    @base ||= Tailwindcss::Style.new(heavy_computation)
  end
end
```

### Precomputed Styles

```ruby
class PrecomputedStyles
  STYLES = {
    button: {
      primary: Tailwindcss::Style.new(
        bg: :blue, text: :white, px: 4, py: 2
      ).freeze,
      secondary: Tailwindcss::Style.new(
        bg: :gray_200, text: :gray_900, px: 4, py: 2
      ).freeze
    }
  }.freeze
  
  def self.get(component, variant)
    STYLES.dig(component, variant) || Tailwindcss::Style.new
  end
end
```

## Best Practices

1. **Start with base styles**: Build from general to specific
2. **Use composition over duplication**: Reuse style objects
3. **Keep styles immutable**: Use merge instead of merge!
4. **Name your compositions**: Make intent clear
5. **Test composed styles**: Verify the output

```ruby
# Good: Clear composition
base_button = Tailwindcss::Style.new(px: 4, py: 2)
primary_button = base_button.merge(bg: :blue)
large_primary = primary_button.merge(px: 6, py: 3)

# Avoid: Unclear nesting
button = Tailwindcss::Style.new(px: 4, py: 2)
  .merge(bg: :blue)
  .merge(text: :white)
  .merge(_hover: { bg: :blue_600 })
  .merge(rounded: :md)
```