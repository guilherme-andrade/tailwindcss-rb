# Modifiers

Modifiers in tailwindcss-rb allow you to apply pseudo-classes, pseudo-elements, and other state variations to your styles. Any key that starts with an underscore is treated as a modifier.

## Basic Syntax

```ruby
tailwind(
  bg: :blue,
  _hover: { bg: :blue_600 }
)
# => "bg-blue-500 hover:bg-blue-600"
```

## Pseudo-Classes

### Hover, Focus, and Active

```ruby
tailwind(
  bg: :white,
  _hover: { bg: :gray_100, scale: 105 },
  _focus: { outline: :none, ring: 2, ring_blue: 500 },
  _active: { bg: :gray_200 }
)
```

### Form States

```ruby
tailwind(
  border: :gray_300,
  _focus: { border_blue: 500 },
  _invalid: { border_red: 500 },
  _disabled: { opacity: 50, cursor: :not_allowed }
)
```

### Structural Pseudo-Classes

```ruby
tailwind(
  bg: :white,
  _first: { rounded_t: :lg },
  _last: { rounded_b: :lg, border_b: :none },
  _odd: { bg: :gray_50 },
  _even: { bg: :white }
)
```

## Pseudo-Elements

### Before and After

```ruby
tailwind(
  relative: true,
  _before: {
    content: '[""]',
    absolute: true,
    inset: 0,
    bg: :black,
    opacity: 50
  },
  _after: {
    content: '["→"]',
    ml: 2
  }
)
```

### Other Pseudo-Elements

```ruby
tailwind(
  _placeholder: { text_gray: 400 },
  _selection: { bg: :blue_200 },
  _first_letter: { text: "4xl", font: :bold },
  _marker: { text_blue: 500 }
)
```

## Group Modifiers

### Group Hover

```ruby
# Parent element
def group_container
  tailwind(group: true, p: 4)
end

# Child element that responds to parent hover
def group_child
  tailwind(
    text_gray: 600,
    _group_hover: { text_blue: 600, scale: 110 }
  )
end
```

### Peer Modifiers

```ruby
# Peer element (e.g., checkbox)
def peer_element
  tailwind(peer: true)
end

# Element that responds to peer state
def peer_dependent
  tailwind(
    hidden: true,
    _peer_checked: { block: true }
  )
end
```

## Combining Modifiers

### Stacked Modifiers

```ruby
tailwind(
  bg: :white,
  _hover: {
    bg: :gray_100,
    _first: { bg: :blue_100 }
  },
  _dark: {
    bg: :gray_800,
    _hover: { bg: :gray_700 }
  }
)
```

### Responsive Modifiers

```ruby
tailwind(
  _hover: { bg: :gray_100 },
  **at(:md, _hover: { bg: :blue_100, scale: 105 }),
  **at(:lg, _hover: { bg: :blue_200, scale: 110 })
)
```

## Advanced Patterns

### Complex Button States

```ruby
class ButtonWithStates
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      # Base
      px: 4,
      py: 2,
      bg: :blue,
      text: :white,
      rounded: :md,
      transition: :all,
      
      # Interactive states
      _hover: { 
        bg: :blue_600,
        shadow: :lg,
        "-translate-y": 0.5
      },
      
      _focus: {
        outline: :none,
        ring: 2,
        ring_blue: 500,
        ring_offset: 2
      },
      
      _active: {
        bg: :blue_700,
        scale: 95
      },
      
      _disabled: {
        bg: :gray_400,
        cursor: :not_allowed,
        opacity: 60
      }
    )
  end
end
```

### Form Input with Validation States

```ruby
class ValidatedInput
  include Tailwindcss::Helpers
  
  def style(state = :default)
    base = {
      w: :full,
      px: 3,
      py: 2,
      border: true,
      rounded: :md,
      transition: :colors
    }
    
    states = {
      default: {
        border_gray: 300,
        _focus: { border_blue: 500, ring: 1, ring_blue: 500 },
        _hover: { border_gray: 400 }
      },
      error: {
        border_red: 500,
        _focus: { border_red: 600, ring: 1, ring_red: 500 },
        _hover: { border_red: 600 }
      },
      success: {
        border_green: 500,
        _focus: { border_green: 600, ring: 1, ring_green: 500 },
        _hover: { border_green: 600 }
      }
    }
    
    tailwind(base.merge(states[state]))
  end
end
```

### Card with Hover Effects

```ruby
class InteractiveCard
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      bg: :white,
      rounded: :lg,
      shadow: :md,
      p: 6,
      transition: :all,
      duration: 300,
      cursor: :pointer,
      
      _hover: {
        shadow: :xl,
        "-translate-y": 1,
        _before: {
          opacity: 100
        }
      },
      
      _before: {
        content: '[""]',
        absolute: true,
        inset: 0,
        bg: "gradient-to-r",
        from_blue: 500,
        to_purple: 500,
        rounded: :lg,
        opacity: 0,
        transition: :opacity,
        "-z": 10
      }
    )
  end
end
```

## Modifier Configuration

### Available Modifiers

Configure available modifiers in your initializer:

```ruby
Tailwindcss.configure do |config|
  config.pseudo_selectors = %i[
    hover
    focus
    focus_within
    focus_visible
    active
    visited
    disabled
    checked
    indeterminate
    default
    required
    valid
    invalid
    in_range
    out_of_range
    placeholder_shown
    autofill
    read_only
    first
    last
    odd
    even
    first_of_type
    last_of_type
    only_of_type
    empty
    target
    enabled
    group_hover
    peer_checked
  ]
  
  config.pseudo_elements = %i[
    before
    after
    first_letter
    first_line
    selection
    backdrop
    marker
    placeholder
    file
  ]
end
```

## Usage Tips

### 1. Order Matters

```ruby
# Good: Specific states override general ones
tailwind(
  _hover: { bg: :gray_100 },
  _hover_focus: { bg: :blue_100 }
)
```

### 2. Transition for Smooth Effects

```ruby
tailwind(
  transition: :all,
  duration: 200,
  _hover: { scale: 105, shadow: :lg }
)
```

### 3. Accessibility Considerations

```ruby
# Always provide focus states
tailwind(
  _hover: { bg: :blue_600 },
  _focus: { outline: :none, ring: 2, ring_blue: 500 },
  _focus_visible: { ring: 2 }  # For keyboard navigation
)
```

### 4. Testing States

```ruby
# Force states for testing
tailwind(
  bg: :white,
  "hover:bg": :blue_100,  # Always applied
  _hover: { text: :blue_600 }  # Only on actual hover
)
```

## Common Patterns

### Navigation Links

```ruby
def nav_link_style(active: false)
  tailwind(
    px: 3,
    py: 2,
    text_gray: 600,
    transition: :colors,
    
    _hover: { text_gray: 900, bg: :gray_100 },
    _focus: { outline: :none, bg: :gray_100 },
    
    **(active ? { 
      text_blue: 600,
      font: :semibold,
      _hover: { text_blue: 700 }
    } : {})
  )
end
```

### Interactive List Items

```ruby
def list_item_style
  tailwind(
    p: 4,
    border_b: true,
    border_gray: 200,
    
    _hover: { bg: :gray_50 },
    _last: { border_b: :none },
    _first: { rounded_t: :lg },
    _last: { rounded_b: :lg }
  )
end
```