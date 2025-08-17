# Basic Usage

## The Style Class

At the core of tailwindcss-rb is the `Style` class, which generates Tailwind CSS classes in a Ruby-like way:

```ruby
Tailwindcss::Style.new(bg: :red).to_s
# => "bg-red-500"
```

## Using the Tailwind Helper

The `tailwind` helper provides a convenient way to generate classes:

```ruby
include Tailwindcss::Helpers

tailwind(bg: :red, text: :white)
# => "bg-red-500 text-white"
```

## Common Properties

### Colors

```ruby
tailwind(
  bg: :blue,        # background-color
  text: :white,     # text color
  border: :gray     # border color
)
# => "bg-blue-500 text-white border-gray-500"
```

### Spacing

```ruby
tailwind(
  p: 4,       # padding
  m: 2,       # margin  
  px: 6,      # horizontal padding
  my: 3       # vertical margin
)
# => "p-4 m-2 px-6 my-3"
```

### Typography

```ruby
tailwind(
  text: :lg,          # font size
  font: :bold,        # font weight
  leading: :tight,    # line height
  tracking: :wide     # letter spacing
)
# => "text-lg font-bold leading-tight tracking-wide"
```

### Layout

```ruby
tailwind(
  flex: true,
  justify: :center,
  items: :center,
  gap: 4
)
# => "flex justify-center items-center gap-4"
```

## Working with Shades

Specify color shades using numbers:

```ruby
tailwind(bg: :blue_100, text: :gray_900)
# => "bg-blue-100 text-gray-900"

# Or use the explicit shade syntax
tailwind(bg: [:blue, 100], text: [:gray, 900])
# => "bg-blue-100 text-gray-900"
```

## Boolean Properties

Some properties work as boolean flags:

```ruby
tailwind(
  flex: true,
  hidden: true,
  absolute: true
)
# => "flex hidden absolute"
```

## Sizes and Variants

Many properties accept size variants:

```ruby
tailwind(
  rounded: :lg,     # border radius
  shadow: :xl,      # box shadow
  text: :2xl        # font size
)
# => "rounded-lg shadow-xl text-2xl"
```

## Practical Examples

### Button

```ruby
def button_classes(variant = :primary)
  base = { px: 4, py: 2, rounded: :md, font: :medium }
  
  variants = {
    primary: { bg: :blue, text: :white },
    secondary: { bg: :gray_200, text: :gray_800 },
    danger: { bg: :red, text: :white }
  }
  
  tailwind(base.merge(variants[variant]))
end
```

### Card Container

```ruby
def card_classes
  tailwind(
    bg: :white,
    rounded: :lg,
    shadow: :md,
    p: 6,
    border: true,
    border_gray: 200
  )
end
```

### Form Input

```ruby
def input_classes(error: false)
  base = {
    block: true,
    w: :full,
    px: 3,
    py: 2,
    rounded: :md,
    border: true
  }
  
  state = error ? 
    { border_red: 500, text: :red_900 } : 
    { border_gray: 300, text: :gray_900 }
  
  tailwind(base.merge(state))
end
```

## Next Steps

- Learn about [Modifiers](./modifiers) for hover states and pseudo-selectors
- Explore [Dark Mode](./dark-mode) support
- Master [Responsive Design](./responsive-design) patterns
- Build complex UIs with [Style Composition](./style-composition)