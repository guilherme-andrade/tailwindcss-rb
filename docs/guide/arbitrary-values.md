# Arbitrary Values

tailwindcss-rb supports Tailwind's arbitrary value syntax, allowing you to use custom values that aren't part of the default design system.

## Basic Syntax

Wrap arbitrary values in square brackets `[]`:

```ruby
tailwind(bg: "[#1da1f2]")
# => "bg-[#1da1f2]"

tailwind(top: "[117px]")
# => "top-[117px]"
```

## Common Use Cases

### Custom Colors

```ruby
# Hex colors
tailwind(bg: "[#ff6b6b]", text: "[#4ecdc4]")

# RGB/RGBA
tailwind(bg: "[rgb(255,0,0)]")
tailwind(bg: "[rgba(0,0,0,0.5)]")

# HSL
tailwind(bg: "[hsl(200,100%,50%)]")
```

### Custom Spacing

```ruby
# Specific pixel values
tailwind(p: "[17px]", m: "[23px]")

# Percentages
tailwind(w: "[33%]", h: "[66%]")

# Calc expressions
tailwind(w: "[calc(100%-2rem)]")
tailwind(h: "[calc(100vh-80px)]")
```

### Background Images

```ruby
# URL images
tailwind(bg: "[url('/images/hero.jpg')]")

# Gradients
tailwind(bg: "[linear-gradient(45deg,#667eea,#764ba2)]")

# Complex gradients
tailwind(
  bg: "[radial-gradient(circle_at_center,#667eea_0%,#764ba2_100%)]"
)
```

## Advanced Patterns

### Custom Properties with Fallbacks

```ruby
def with_css_variable(property, variable, fallback)
  tailwind(
    "#{property}": "[var(#{variable},#{fallback})]"
  )
end

# Usage
with_css_variable(:bg, "--primary-color", "#3b82f6")
# => "bg-[var(--primary-color,#3b82f6)]"
```

### Dynamic Values

```ruby
class DynamicStyles
  include Tailwindcss::Helpers
  
  def custom_spacing(value)
    tailwind(
      p: "[#{value}px]",
      m: "[#{value * 0.5}px]"
    )
  end
  
  def custom_color(hex)
    tailwind(
      bg: "[#{hex}]",
      border: "[#{darken(hex, 10)}]"
    )
  end
  
  private
  
  def darken(hex, percent)
    # Color darkening logic
    hex
  end
end
```

### Grid and Flexbox

```ruby
# Custom grid templates
tailwind(
  grid: true,
  "grid-cols": "[1fr_2fr_1fr]",
  "grid-rows": "[200px_1fr_100px]"
)

# Custom flex values
tailwind(
  flex: "[2_2_0%]",
  basis: "[250px]"
)
```

## Component Examples

### Custom Card with Arbitrary Values

```ruby
class CustomCard
  include Tailwindcss::Helpers
  
  def style(options = {})
    tailwind(
      bg: options[:bg_color] || "[#f8f9fa]",
      p: "[18px]",
      rounded: "[12px]",
      shadow: "[0_4px_6px_rgba(0,0,0,0.07)]",
      border: "[1px]",
      border_color: "[#e9ecef]"
    )
  end
end
```

### Custom Button with Gradients

```ruby
class GradientButton
  include Tailwindcss::Helpers
  
  def style(from_color, to_color, angle = 45)
    tailwind(
      bg: "[linear-gradient(#{angle}deg,#{from_color},#{to_color})]",
      text: :white,
      px: "[24px]",
      py: "[12px]",
      rounded: "[8px]",
      shadow: "[0_4px_14px_rgba(0,0,0,0.1)]",
      _hover: {
        shadow: "[0_6px_20px_rgba(0,0,0,0.15)]",
        transform: "[translateY(-2px)]"
      }
    )
  end
end

# Usage
button = GradientButton.new
button.style("#667eea", "#764ba2", 135)
```

### Custom Animation Timing

```ruby
class AnimatedElement
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      transition: "[all_0.3s_cubic-bezier(0.4,0,0.2,1)]",
      duration: "[350ms]",
      delay: "[50ms]",
      _hover: {
        transform: "[scale(1.05)_rotate(2deg)]"
      }
    )
  end
end
```

## Working with CSS Functions

### Transform Functions

```ruby
tailwind(
  transform: true,
  rotate: "[23deg]",
  scale: "[1.15]",
  translate_x: "[12px]",
  skew_y: "[3deg]"
)
```

### Filter Functions

```ruby
tailwind(
  filter: true,
  blur: "[2px]",
  brightness: "[1.2]",
  contrast: "[1.1]",
  grayscale: "[50%]"
)
```

### CSS Variables

```ruby
# Define CSS variables
def css_variables
  {
    "--primary": "#3b82f6",
    "--secondary": "#10b981",
    "--spacing-unit": "8px"
  }
end

# Use CSS variables
tailwind(
  bg: "[var(--primary)]",
  p: "[calc(var(--spacing-unit)*2)]"
)
```

## Complex Examples

### Glassmorphism Effect

```ruby
class GlassmorphicCard
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      bg: "[rgba(255,255,255,0.1)]",
      backdrop_blur: "[10px]",
      border: "[1px]",
      border_color: "[rgba(255,255,255,0.2)]",
      shadow: "[0_8px_32px_rgba(31,38,135,0.37)]",
      rounded: "[20px]",
      p: "[32px]"
    )
  end
end
```

### Neumorphism Design

```ruby
class NeumorphicButton
  include Tailwindcss::Helpers
  
  def style(bg_color = "#e0e5ec")
    tailwind(
      bg: "[#{bg_color}]",
      shadow: "[9px_9px_16px_#a3b1c6,-9px_-9px_16px_#ffffff]",
      rounded: "[20px]",
      px: "[32px]",
      py: "[16px]",
      _hover: {
        shadow: "[inset_9px_9px_16px_#a3b1c6,inset_-9px_-9px_16px_#ffffff]"
      }
    )
  end
end
```

### Custom Clip Path

```ruby
class ClippedElement
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      "clip-path": "[polygon(0_0,100%_0,100%_85%,0_100%)]",
      bg: "[linear-gradient(135deg,#667eea,#764ba2)]",
      h: "[400px]"
    )
  end
end
```

## Content Property

For pseudo-elements with content:

```ruby
# Empty content
tailwind(_before: { content: '[""]' })

# Text content
tailwind(_before: { content: '["→"]' })

# Unicode characters
tailwind(_before: { content: '["\\2022"]' })  # Bullet point

# Attribute values
tailwind(_after: { content: "[attr(data-label)]" })
```

## Best Practices

1. **Use design tokens when possible**: Prefer Tailwind's built-in values
2. **Keep arbitrary values consistent**: Define them in constants
3. **Document custom values**: Explain why they're needed
4. **Consider extraction**: Move repeated arbitrary values to CSS variables
5. **Validate values**: Ensure they're valid CSS

```ruby
# Good: Consistent arbitrary values
class BrandColors
  PRIMARY = "[#1da1f2]"
  SECONDARY = "[#14171a]"
  ACCENT = "[#657786]"
end

tailwind(bg: BrandColors::PRIMARY)

# Avoid: Inline arbitrary values scattered
tailwind(bg: "[#1da1f2]")  # In one file
tailwind(bg: "[#1da1f3]")  # Slightly different in another
```

## Escaping Special Characters

When using arbitrary values with special characters:

```ruby
# Spaces: use underscores
tailwind(font_family: "[Inter_UI,sans-serif]")

# Commas: use underscores or escape
tailwind(shadow: "[0_0_0_3px_rgba(66,153,225,0.5)]")

# Quotes: escape properly
tailwind(content: '["\\"Quote\\""]')
```