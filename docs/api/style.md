# Style API

The `Tailwindcss::Style` class is the core building block for generating Tailwind CSS classes in Ruby.

## Class Methods

### new

Creates a new Style instance with the given attributes.

```ruby
style = Tailwindcss::Style.new(bg: :blue, text: :white, p: 4)
```

**Parameters:**
- `**attributes` - Hash of Tailwind properties and values

**Returns:** `Tailwindcss::Style` instance

## Instance Methods

### to_s

Converts the style to a string of Tailwind classes.

```ruby
style = Tailwindcss::Style.new(bg: :blue, text: :white)
style.to_s # => "bg-blue-500 text-white"
```

**Returns:** `String` - Space-separated Tailwind classes

### merge

Merges another style or hash into this style, creating a new instance.

```ruby
base = Tailwindcss::Style.new(p: 4, rounded: :md)
extended = base.merge(bg: :blue, text: :white)
# => Style with p: 4, rounded: :md, bg: :blue, text: :white
```

**Parameters:**
- `other` - Another Style instance or Hash

**Returns:** `Tailwindcss::Style` - New merged instance

### merge!

Merges in place (mutates the current instance).

```ruby
style = Tailwindcss::Style.new(p: 4)
style.merge!(bg: :blue)
# style now has both p: 4 and bg: :blue
```

**Parameters:**
- `other` - Another Style instance or Hash

**Returns:** `self`

### +

Alias for merge, allows using + operator.

```ruby
button = base_style + Tailwindcss::Style.new(bg: :blue)
```

**Parameters:**
- `other` - Another Style instance or Hash

**Returns:** `Tailwindcss::Style` - New merged instance

### with

Creates a new instance with specific attributes replaced.

```ruby
original = Tailwindcss::Style.new(bg: :blue, text: :white, p: 4)
modified = original.with(bg: :red)
# => Style with bg: :red, text: :white, p: 4
```

**Parameters:**
- `**attributes` - Attributes to override

**Returns:** `Tailwindcss::Style` - New instance with modifications

### except

Creates a new instance without specified attributes.

```ruby
original = Tailwindcss::Style.new(bg: :blue, text: :white, p: 4)
minimal = original.except(:bg, :text)
# => Style with only p: 4
```

**Parameters:**
- `*keys` - Keys to remove

**Returns:** `Tailwindcss::Style` - New instance without specified keys

### empty?

Checks if the style has no attributes.

```ruby
Tailwindcss::Style.new.empty? # => true
Tailwindcss::Style.new(bg: :blue).empty? # => false
```

**Returns:** `Boolean`

### present?

Checks if the style has any attributes.

```ruby
Tailwindcss::Style.new.present? # => false
Tailwindcss::Style.new(bg: :blue).present? # => true
```

**Returns:** `Boolean`

### to_h

Returns the raw attributes hash.

```ruby
style = Tailwindcss::Style.new(bg: :blue, text: :white)
style.to_h # => { bg: :blue, text: :white }
```

**Returns:** `Hash`

## Composition Examples

### Building Complex Styles

```ruby
# Base button style
button_base = Tailwindcss::Style.new(
  px: 4,
  py: 2,
  rounded: :md,
  font: :medium,
  transition: :colors
)

# Primary variant
primary_button = button_base.merge(
  bg: :blue,
  text: :white,
  _hover: { bg: :blue_600 }
)

# Large size variant
large_button = primary_button.with(
  px: 6,
  py: 3,
  text: :lg
)

# Disabled state
disabled_button = large_button.merge(
  opacity: 50,
  cursor: :not_allowed
).except(:_hover)
```

### Component Pattern

```ruby
class ButtonComponent
  def self.style(variant: :primary, size: :md, disabled: false)
    base = Tailwindcss::Style.new(
      inline_flex: true,
      items: :center,
      justify: :center,
      rounded: :md,
      font: :medium,
      transition: :colors
    )
    
    variant_styles = {
      primary: { bg: :blue, text: :white },
      secondary: { bg: :gray_200, text: :gray_900 },
      danger: { bg: :red, text: :white }
    }
    
    size_styles = {
      sm: { px: 3, py: 1.5, text: :sm },
      md: { px: 4, py: 2, text: :base },
      lg: { px: 6, py: 3, text: :lg }
    }
    
    style = base
      .merge(variant_styles[variant])
      .merge(size_styles[size])
    
    if disabled
      style = style.merge(opacity: 50, cursor: :not_allowed)
    end
    
    style
  end
end
```

## Advanced Usage

### Conditional Merging

```ruby
style = Tailwindcss::Style.new(p: 4)

style = style.merge(bg: :blue) if primary?
style = style.merge(border: :red) if has_error?
style = style.merge(_hover: { scale: 105 }) if interactive?
```

### Dynamic Composition

```ruby
def build_style(options = {})
  Tailwindcss::Style.new.tap do |style|
    style.merge!(base_styles)
    style.merge!(size_styles[options[:size]]) if options[:size]
    style.merge!(variant_styles[options[:variant]]) if options[:variant]
    style.merge!(options[:custom]) if options[:custom]
  end
end
```

## Performance Notes

- Style instances are immutable by default (except for `merge!`)
- Use `merge` for functional composition
- Use `merge!` when building styles in loops for better performance
- Styles are cached internally for repeated use