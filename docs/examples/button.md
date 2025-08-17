# Button Component Examples

Comprehensive button patterns using tailwindcss-rb.

## Basic Button

```ruby
class Button
  include Tailwindcss::Helpers
  
  def self.basic
    tailwind(
      px: 4,
      py: 2,
      bg: :blue,
      text: :white,
      rounded: :md,
      font: :medium
    )
  end
end
```

## Complete Button System

```ruby
class ButtonComponent
  include Tailwindcss::Helpers
  
  VARIANTS = {
    primary: {
      bg: :blue,
      text: :white,
      border: :blue,
      _hover: { bg: :blue_600, border: :blue_600 },
      _focus: { ring: 2, ring_blue: 500, ring_offset: 2 },
      _active: { bg: :blue_700 }
    },
    secondary: {
      bg: :white,
      text: :gray_700,
      border: :gray_300,
      _hover: { bg: :gray_50, text: :gray_900 },
      _focus: { ring: 2, ring_gray: 500, ring_offset: 2 },
      _active: { bg: :gray_100 }
    },
    success: {
      bg: :green,
      text: :white,
      border: :green,
      _hover: { bg: :green_600, border: :green_600 },
      _focus: { ring: 2, ring_green: 500, ring_offset: 2 },
      _active: { bg: :green_700 }
    },
    danger: {
      bg: :red,
      text: :white,
      border: :red,
      _hover: { bg: :red_600, border: :red_600 },
      _focus: { ring: 2, ring_red: 500, ring_offset: 2 },
      _active: { bg: :red_700 }
    },
    warning: {
      bg: :yellow_400,
      text: :gray_900,
      border: :yellow_400,
      _hover: { bg: :yellow_500, border: :yellow_500 },
      _focus: { ring: 2, ring_yellow: 500, ring_offset: 2 },
      _active: { bg: :yellow_600 }
    },
    ghost: {
      bg: :transparent,
      text: :gray_600,
      border: :transparent,
      _hover: { bg: :gray_100, text: :gray_900 },
      _focus: { ring: 2, ring_gray: 500, ring_offset: 2 },
      _active: { bg: :gray_200 }
    },
    outline: {
      bg: :transparent,
      text: :blue,
      border: :blue,
      _hover: { bg: :blue_50 },
      _focus: { ring: 2, ring_blue: 500, ring_offset: 2 },
      _active: { bg: :blue_100 }
    }
  }.freeze
  
  SIZES = {
    xs: {
      px: 2.5,
      py: 1.5,
      text: :xs,
      rounded: :sm
    },
    sm: {
      px: 3,
      py: 2,
      text: :sm,
      rounded: :md
    },
    md: {
      px: 4,
      py: 2,
      text: :base,
      rounded: :md
    },
    lg: {
      px: 4,
      py: 2,
      text: :lg,
      rounded: :md
    },
    xl: {
      px: 6,
      py: 3,
      text: :xl,
      rounded: :lg
    }
  }.freeze
  
  def initialize(
    variant: :primary,
    size: :md,
    disabled: false,
    loading: false,
    full_width: false,
    icon_left: nil,
    icon_right: nil,
    **custom_classes
  )
    @variant = variant
    @size = size
    @disabled = disabled
    @loading = loading
    @full_width = full_width
    @icon_left = icon_left
    @icon_right = icon_right
    @custom_classes = custom_classes
  end
  
  def classes
    tailwind(
      **base_classes,
      **variant_classes,
      **size_classes,
      **state_classes,
      **width_classes,
      **@custom_classes
    )
  end
  
  private
  
  def base_classes
    {
      inline_flex: true,
      items: :center,
      justify: :center,
      font: :medium,
      border: true,
      transition: :all,
      duration: 150,
      select: :none,
      cursor: :pointer,
      outline: :none,
      relative: true
    }
  end
  
  def variant_classes
    VARIANTS[@variant] || VARIANTS[:primary]
  end
  
  def size_classes
    SIZES[@size] || SIZES[:md]
  end
  
  def state_classes
    return {} unless @disabled || @loading
    
    {
      opacity: @disabled ? 50 : 75,
      cursor: @disabled ? :not_allowed : :wait,
      pointer_events: @disabled ? :none : :auto
    }
  end
  
  def width_classes
    @full_width ? { w: :full } : {}
  end
end
```

## Usage Examples

### In Views

```erb
<!-- Basic buttons -->
<button class="<%= ButtonComponent.new.classes %>">
  Default Button
</button>

<button class="<%= ButtonComponent.new(variant: :secondary).classes %>">
  Secondary Button
</button>

<button class="<%= ButtonComponent.new(variant: :danger, size: :lg).classes %>">
  Large Danger Button
</button>

<!-- With states -->
<button class="<%= ButtonComponent.new(disabled: true).classes %>" disabled>
  Disabled Button
</button>

<button class="<%= ButtonComponent.new(loading: true).classes %>">
  <svg class="animate-spin h-5 w-5 mr-3" viewBox="0 0 24 24">
    <!-- Loading spinner -->
  </svg>
  Processing...
</button>

<!-- Full width -->
<button class="<%= ButtonComponent.new(full_width: true).classes %>">
  Full Width Button
</button>
```

### Button Group

```ruby
class ButtonGroup
  include Tailwindcss::Helpers
  
  def wrapper_classes
    tailwind(
      inline_flex: true,
      rounded: :md,
      shadow: :sm,
      isolate: true
    )
  end
  
  def button_classes(position)
    base = {
      px: 4,
      py: 2,
      bg: :white,
      text: :gray_700,
      border: :gray_300,
      font: :medium,
      text: :sm,
      _hover: { bg: :gray_50 },
      _focus: { z: 10, ring: 2, ring_blue: 500 }
    }
    
    position_styles = case position
    when :first
      {
        rounded_l: :md,
        border_r: 0
      }
    when :last
      {
        rounded_r: :md,
        "-ml": "px"
      }
    when :middle
      {
        border_r: 0,
        "-ml": "px"
      }
    else
      { rounded: :md }
    end
    
    tailwind(base.merge(position_styles))
  end
end
```

```erb
<div class="<%= ButtonGroup.new.wrapper_classes %>">
  <button class="<%= ButtonGroup.new.button_classes(:first) %>">Years</button>
  <button class="<%= ButtonGroup.new.button_classes(:middle) %>">Months</button>
  <button class="<%= ButtonGroup.new.button_classes(:last) %>">Days</button>
</div>
```

### Icon Buttons

```ruby
class IconButton
  include Tailwindcss::Helpers
  
  def self.style(size: :md, variant: :primary, rounded: true)
    sizes = {
      sm: { p: 1.5 },
      md: { p: 2 },
      lg: { p: 3 }
    }
    
    variants = {
      primary: { bg: :blue, text: :white, _hover: { bg: :blue_600 } },
      secondary: { bg: :gray_200, text: :gray_700, _hover: { bg: :gray_300 } }
    }
    
    tailwind(
      **sizes[size],
      **variants[variant],
      rounded: rounded ? :full : :md,
      inline_flex: true,
      items: :center,
      justify: :center,
      transition: :colors,
      _focus: { outline: :none, ring: 2, ring_offset: 2 }
    )
  end
end
```

### Split Button

```ruby
class SplitButton
  include Tailwindcss::Helpers
  
  def main_button_classes
    tailwind(
      px: 4,
      py: 2,
      bg: :blue,
      text: :white,
      font: :medium,
      rounded_l: :md,
      _hover: { bg: :blue_600 },
      _focus: { outline: :none, ring: 2, ring_blue: 500 }
    )
  end
  
  def dropdown_button_classes
    tailwind(
      px: 2,
      py: 2,
      bg: :blue,
      text: :white,
      border_l: true,
      border_blue: 400,
      rounded_r: :md,
      _hover: { bg: :blue_600 },
      _focus: { outline: :none, ring: 2, ring_blue: 500 }
    )
  end
end
```

### Social Media Buttons

```ruby
class SocialButton
  include Tailwindcss::Helpers
  
  PLATFORMS = {
    facebook: {
      bg: "[#1877f2]",
      _hover: { bg: "[#166fe5]" }
    },
    twitter: {
      bg: "[#1da1f2]",
      _hover: { bg: "[#1a91da]" }
    },
    github: {
      bg: :gray_900,
      _hover: { bg: :gray_800 }
    },
    google: {
      bg: :white,
      text: :gray_700,
      border: :gray_300,
      _hover: { bg: :gray_50 }
    },
    linkedin: {
      bg: "[#0077b5]",
      _hover: { bg: "[#006399]" }
    }
  }.freeze
  
  def self.style(platform, **options)
    base = {
      px: 4,
      py: 2,
      text: :white,
      rounded: :md,
      font: :medium,
      inline_flex: true,
      items: :center,
      gap: 2,
      transition: :colors,
      _focus: { outline: :none, ring: 2, ring_offset: 2 }
    }
    
    tailwind(
      **base,
      **PLATFORMS[platform],
      **options
    )
  end
end
```

## Advanced Patterns

### Animated Button

```ruby
class AnimatedButton
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      px: 6,
      py: 3,
      bg: :gradient_to_r,
      from_blue: 500,
      to_purple: 600,
      text: :white,
      font: :bold,
      rounded: :lg,
      relative: true,
      overflow: :hidden,
      transform: true,
      transition: :all,
      duration: 300,
      _hover: {
        scale: 105,
        shadow: :lg
      },
      _active: {
        scale: 95
      },
      _before: {
        content: '[""]',
        absolute: true,
        top: 0,
        left: "-100%",
        w: :full,
        h: :full,
        bg: :gradient_to_r,
        from_transparent: true,
        via_white: true,
        to_transparent: true,
        opacity: 30,
        transition: :all,
        duration: 500
      },
      "_hover_before": {
        left: "100%"
      }
    )
  end
end
```

### 3D Button

```ruby
class ThreeDButton
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      px: 6,
      py: 3,
      bg: :blue,
      text: :white,
      font: :bold,
      rounded: :lg,
      shadow: "[0_4px_0_rgb(30,64,175)]",
      transform: true,
      transition: :all,
      duration: 150,
      _hover: {
        translate_y: "-2px",
        shadow: "[0_6px_0_rgb(30,64,175)]"
      },
      _active: {
        translate_y: "2px",
        shadow: "[0_0_0_rgb(30,64,175)]"
      }
    )
  end
end
```

## Accessibility

```ruby
class AccessibleButton
  include Tailwindcss::Helpers
  
  def style
    tailwind(
      # Visual styles
      px: 4,
      py: 2,
      bg: :blue,
      text: :white,
      rounded: :md,
      
      # Focus styles for keyboard navigation
      _focus: {
        outline: :none,
        ring: 2,
        ring_blue: 500,
        ring_offset: 2
      },
      
      # Focus visible for better accessibility
      _focus_visible: {
        ring: 2,
        ring_blue: 500,
        ring_offset: 2
      },
      
      # High contrast mode support
      "@media (prefers-contrast: high)": {
        border: 2,
        border_white: true
      }
    )
  end
end
```