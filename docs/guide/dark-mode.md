# Dark Mode

tailwindcss-rb provides elegant helpers for implementing dark mode in your applications.

## Using the dark() Helper

The `dark()` helper creates dark mode variants of your styles:

```ruby
tailwind(
  bg: :white,
  text: :black,
  **dark(bg: :gray_900, text: :white)
)
# => "bg-white text-black dark:bg-gray-900 dark:text-white"
```

## Basic Examples

### Simple Dark Mode

```ruby
# Card with dark mode support
tailwind(
  bg: :white,
  border: :gray_200,
  **dark(
    bg: :gray_800,
    border: :gray_700
  )
)
```

### Dark Mode with Hover States

```ruby
tailwind(
  bg: :white,
  **dark(
    bg: :gray_900,
    _hover: { bg: :gray_800 }
  )
)
# => "bg-white dark:bg-gray-900 dark:hover:bg-gray-800"
```

## Component Patterns

### Dark Mode Card Component

```ruby
class DarkModeCard
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      # Light mode
      bg: :white,
      text: :gray_900,
      border: :gray_200,
      shadow: :md,
      
      # Dark mode
      **dark(
        bg: :gray_800,
        text: :gray_100,
        border: :gray_700,
        shadow: :xl
      ),
      
      # Common styles
      rounded: :lg,
      p: 6
    )
  end
end
```

### Form Input with Dark Mode

```ruby
def input_style
  tailwind(
    # Base styles
    block: true,
    w: :full,
    px: 3,
    py: 2,
    rounded: :md,
    border: true,
    
    # Light mode
    bg: :white,
    border_gray: 300,
    text: :gray_900,
    placeholder_gray: 400,
    
    # Dark mode
    **dark(
      bg: :gray_700,
      border_gray: 600,
      text: :white,
      placeholder_gray: 400
    ),
    
    # Focus states for both modes
    _focus: {
      outline: :none,
      ring: 2,
      ring_blue: 500,
      border: :transparent
    }
  )
end
```

## Advanced Patterns

### Nested Dark Mode Modifiers

```ruby
tailwind(
  bg: :white,
  **dark(
    bg: :gray_900,
    _hover: { 
      bg: :gray_800,
      text: :blue_400
    },
    _focus: {
      ring: 2,
      ring_blue: 500
    }
  )
)
```

### Combining Dark Mode with Responsive

```ruby
tailwind(
  # Mobile first
  p: 2,
  bg: :white,
  
  # Dark mode for all sizes
  **dark(bg: :gray_900),
  
  # Tablet and up
  **at(:md, 
    p: 4,
    **dark(bg: :gray_800)
  ),
  
  # Desktop
  **at(:lg,
    p: 6,
    **dark(bg: :gray_700)
  )
)
```

## Color Scheme Strategies

### Semantic Color Variables

```ruby
module ColorScheme
  def light_colors
    {
      bg_primary: :white,
      bg_secondary: :gray_50,
      text_primary: :gray_900,
      text_secondary: :gray_600,
      border: :gray_200
    }
  end
  
  def dark_colors
    {
      bg_primary: :gray_900,
      bg_secondary: :gray_800,
      text_primary: :gray_100,
      text_secondary: :gray_400,
      border: :gray_700
    }
  end
  
  def themed_style
    tailwind(
      bg: light_colors[:bg_primary],
      text: light_colors[:text_primary],
      border: light_colors[:border],
      
      **dark(
        bg: dark_colors[:bg_primary],
        text: dark_colors[:text_primary],
        border: dark_colors[:border]
      )
    )
  end
end
```

### Theme-aware Components

```ruby
class ThemedButton
  include Tailwindcss::Helpers
  
  THEMES = {
    light: {
      primary: { bg: :blue_500, text: :white },
      secondary: { bg: :gray_200, text: :gray_900 }
    },
    dark: {
      primary: { bg: :blue_600, text: :white },
      secondary: { bg: :gray_700, text: :gray_100 }
    }
  }.freeze
  
  def style(variant: :primary)
    tailwind(
      # Common styles
      px: 4,
      py: 2,
      rounded: :md,
      font: :medium,
      
      # Light theme
      **THEMES[:light][variant],
      
      # Dark theme
      **dark(THEMES[:dark][variant])
    )
  end
end
```

## Implementation Tips

### 1. Use Class Strategy

Enable dark mode in your Tailwind config:

```javascript
// tailwind.config.js
module.exports = {
  darkMode: 'class', // or 'media'
  // ...
}
```

Toggle dark mode with JavaScript:

```javascript
// Toggle dark class on html element
document.documentElement.classList.toggle('dark')
```

### 2. System Preference Detection

```javascript
// Detect and apply system preference
if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
  document.documentElement.classList.add('dark')
}

// Listen for changes
window.matchMedia('(prefers-color-scheme: dark)')
  .addEventListener('change', e => {
    if (e.matches) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  })
```

### 3. Persist User Preference

```javascript
// Save preference
localStorage.setItem('theme', 'dark')

// Load preference on page load
const theme = localStorage.getItem('theme')
if (theme === 'dark') {
  document.documentElement.classList.add('dark')
}
```

## Best Practices

1. **Group dark mode styles**: Keep all dark mode variants together using the `dark()` helper
2. **Use semantic colors**: Define color schemes that make sense in both modes
3. **Test both modes**: Always verify your UI looks good in both light and dark modes
4. **Consider contrast**: Ensure sufficient contrast ratios in both modes
5. **Smooth transitions**: Add transitions when switching between modes

```ruby
def mode_transition
  tailwind(
    transition: :colors,
    duration: 200,
    ease: :in_out
  )
end
```