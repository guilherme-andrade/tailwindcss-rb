# Responsive Design

Build responsive layouts using tailwindcss-rb's `at()` helper for clean, maintainable breakpoint management.

## Using the at() Helper

The `at()` helper applies styles at specific breakpoints:

```ruby
tailwind(
  p: 2,                  # All sizes
  **at(:md, p: 4),      # Medium and up
  **at(:lg, p: 6)       # Large and up
)
# => "p-2 md:p-4 lg:p-6"
```

## Available Breakpoints

Default breakpoints follow Tailwind's mobile-first approach:

- `xs` - 0px (default, no prefix needed)
- `sm` - 640px and up
- `md` - 768px and up  
- `lg` - 1024px and up
- `xl` - 1280px and up
- `2xl` - 1536px and up

## Basic Responsive Patterns

### Responsive Padding

```ruby
tailwind(
  p: { base: 2, sm: 3, md: 4, lg: 6, xl: 8 }
)
# Alternative syntax
tailwind(
  p: 2,
  **at(:sm, p: 3),
  **at(:md, p: 4),
  **at(:lg, p: 6),
  **at(:xl, p: 8)
)
```

### Responsive Typography

```ruby
tailwind(
  text: :sm,              # Mobile
  **at(:md, text: :base), # Tablet
  **at(:lg, text: :lg),   # Desktop
  **at(:xl, text: :xl)    # Large screens
)
```

### Responsive Grid

```ruby
tailwind(
  grid: true,
  cols: 1,                    # Mobile: 1 column
  gap: 4,
  **at(:sm, cols: 2),        # Small: 2 columns
  **at(:md, cols: 3),        # Medium: 3 columns
  **at(:lg, cols: 4, gap: 6) # Large: 4 columns, bigger gap
)
```

## Component Examples

### Responsive Navigation

```ruby
class ResponsiveNav
  include Tailwindcss::Helpers
  
  def container_style
    tailwind(
      flex: true,
      justify: :between,
      items: :center,
      px: 4,
      py: 3,
      
      **at(:md, px: 6),
      **at(:lg, px: 8)
    )
  end
  
  def menu_style
    tailwind(
      # Mobile: hidden
      hidden: true,
      
      # Desktop: visible flex
      **at(:md, 
        flex: true,
        space_x: 4
      )
    )
  end
  
  def mobile_menu_button
    tailwind(
      # Mobile: visible
      block: true,
      
      # Desktop: hidden
      **at(:md, hidden: true)
    )
  end
end
```

### Responsive Card Grid

```ruby
class CardGrid
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      grid: true,
      gap: 4,
      
      # Mobile: 1 column
      cols: 1,
      
      # Tablet: 2 columns
      **at(:sm, cols: 2, gap: 6),
      
      # Desktop: 3 columns
      **at(:lg, cols: 3, gap: 8),
      
      # Wide: 4 columns
      **at(:xl, cols: 4)
    )
  end
end
```

### Responsive Hero Section

```ruby
class HeroSection
  include Tailwindcss::Helpers
  
  def container_style
    tailwind(
      px: 4,
      py: 12,
      text: :center,
      
      **at(:md, 
        px: 6,
        py: 16,
        text: :left
      ),
      
      **at(:lg,
        px: 8,
        py: 20
      )
    )
  end
  
  def title_style
    tailwind(
      text: "3xl",
      font: :bold,
      mb: 4,
      
      **at(:sm, text: "4xl"),
      **at(:md, text: "5xl", mb: 6),
      **at(:lg, text: "6xl")
    )
  end
  
  def description_style
    tailwind(
      text: :base,
      text_gray: 600,
      mb: 8,
      
      **at(:md, text: :lg),
      **at(:lg, text: :xl, mb: 12)
    )
  end
end
```

## Advanced Patterns

### Combining Responsive with Dark Mode

```ruby
tailwind(
  # Base mobile styles
  p: 2,
  bg: :white,
  
  # Dark mode for all sizes
  **dark(bg: :gray_900),
  
  # Tablet with dark variant
  **at(:md,
    p: 4,
    **dark(bg: :gray_800)
  ),
  
  # Desktop with dark variant  
  **at(:lg,
    p: 6,
    **dark(bg: :gray_700)
  )
)
```

### Responsive Modifiers

```ruby
tailwind(
  # Different hover effects per breakpoint
  _hover: { bg: :gray_100 },
  
  **at(:md, _hover: { bg: :blue_50, scale: 105 }),
  **at(:lg, _hover: { bg: :blue_100, scale: 110 })
)
```

### Container Queries (Tailwind CSS v3.2+)

```ruby
# Container setup
def container_style
  tailwind(container_type: :inline_size)
end

# Responsive to container
def contained_element
  tailwind(
    text: :sm,
    "@sm": { text: :base },  # Container query
    "@md": { text: :lg },
    "@lg": { text: :xl }
  )
end
```

## Layout Patterns

### Responsive Sidebar Layout

```ruby
class SidebarLayout
  include Tailwindcss::Helpers
  
  def wrapper_style
    tailwind(
      flex: true,
      flex_col: true,
      
      **at(:md, flex_row: true)
    )
  end
  
  def sidebar_style
    tailwind(
      w: :full,
      mb: 4,
      
      **at(:md, 
        w: 64,    # Fixed width on desktop
        mb: 0,
        mr: 6
      )
    )
  end
  
  def main_content_style
    tailwind(
      flex: 1,   # Take remaining space
      w: :full
    )
  end
end
```

### Responsive Table

```ruby
class ResponsiveTable
  include Tailwindcss::Helpers
  
  def wrapper_style
    tailwind(
      overflow_x: :auto,    # Mobile: horizontal scroll
      
      **at(:lg, overflow_x: :visible)  # Desktop: no scroll
    )
  end
  
  def table_style
    tailwind(
      w: :full,
      min_w: :full,
      
      **at(:md, min_w: 0)   # Remove min width on larger screens
    )
  end
  
  def cell_style
    tailwind(
      px: 2,
      py: 2,
      text: :xs,
      
      **at(:sm, px: 3, text: :sm),
      **at(:md, px: 4, py: 3, text: :base)
    )
  end
end
```

## Responsive Utilities

### Hide/Show Elements

```ruby
# Show only on mobile
tailwind(
  block: true,
  **at(:md, hidden: true)
)

# Show only on desktop
tailwind(
  hidden: true,
  **at(:md, block: true)
)

# Different display types
tailwind(
  hidden: true,
  **at(:sm, block: true),
  **at(:md, flex: true),
  **at(:lg, grid: true)
)
```

### Responsive Flexbox

```ruby
tailwind(
  flex: true,
  flex_col: true,        # Mobile: column
  
  **at(:md, 
    flex_row: true,      # Desktop: row
    justify: :between,
    items: :center
  )
)
```

## Best Practices

1. **Mobile First**: Start with mobile styles, add complexity for larger screens
2. **Logical Breakpoints**: Choose breakpoints based on content, not devices
3. **Test Thoroughly**: Check all breakpoints, not just mobile and desktop
4. **Avoid Too Many**: Use 3-4 breakpoints maximum for maintainability
5. **Group Related**: Keep responsive variants together

```ruby
# Good: Grouped by property
tailwind(
  # Padding progression
  p: 2,
  **at(:sm, p: 3),
  **at(:md, p: 4),
  **at(:lg, p: 6),
  
  # Text size progression  
  text: :sm,
  **at(:md, text: :base),
  **at(:lg, text: :lg)
)

# Avoid: Mixed properties
tailwind(
  p: 2,
  text: :sm,
  **at(:sm, p: 3),
  **at(:md, text: :base),
  **at(:md, p: 4),
  **at(:lg, text: :lg),
  **at(:lg, p: 6)
)
```