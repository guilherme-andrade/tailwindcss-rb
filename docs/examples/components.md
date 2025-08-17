# Component Examples

Build reusable UI components using tailwindcss-rb's powerful composition patterns.

## Basic Component Structure

```ruby
class UIComponent
  include Tailwindcss::Helpers
  
  attr_reader :options
  
  def initialize(**options)
    @options = options
  end
  
  def style
    base_style
      .merge(variant_style)
      .merge(size_style)
      .merge(state_style)
      .merge(custom_style)
  end
  
  def to_s
    style.to_s
  end
  
  private
  
  def base_style
    Tailwindcss::Style.new
  end
  
  def variant_style
    {}
  end
  
  def size_style
    {}
  end
  
  def state_style
    {}
  end
  
  def custom_style
    options[:class] || {}
  end
end
```

## Button Component

```ruby
class ButtonComponent < UIComponent
  VARIANTS = {
    primary: {
      bg: :blue,
      text: :white,
      _hover: { bg: :blue_600 },
      _focus: { ring: 2, ring_blue: 500, ring_offset: 2 }
    },
    secondary: {
      bg: :gray_200,
      text: :gray_900,
      _hover: { bg: :gray_300 },
      _focus: { ring: 2, ring_gray: 500, ring_offset: 2 }
    },
    danger: {
      bg: :red,
      text: :white,
      _hover: { bg: :red_600 },
      _focus: { ring: 2, ring_red: 500, ring_offset: 2 }
    },
    ghost: {
      bg: :transparent,
      text: :gray_700,
      _hover: { bg: :gray_100 },
      _focus: { ring: 2, ring_gray: 500, ring_offset: 2 }
    }
  }.freeze
  
  SIZES = {
    xs: { px: 2.5, py: 1.5, text: :xs },
    sm: { px: 3, py: 2, text: :sm },
    md: { px: 4, py: 2, text: :base },
    lg: { px: 4, py: 2, text: :lg },
    xl: { px: 6, py: 3, text: :xl }
  }.freeze
  
  private
  
  def base_style
    Tailwindcss::Style.new(
      inline_flex: true,
      items: :center,
      justify: :center,
      rounded: :md,
      font: :medium,
      transition: :colors,
      duration: 150,
      cursor: :pointer,
      select: :none,
      outline: :none
    )
  end
  
  def variant_style
    VARIANTS[options[:variant] || :primary]
  end
  
  def size_style
    SIZES[options[:size] || :md]
  end
  
  def state_style
    return {} unless options[:disabled]
    
    {
      opacity: 50,
      cursor: :not_allowed,
      pointer_events: :none
    }
  end
end

# Usage
button = ButtonComponent.new(variant: :primary, size: :lg)
# => "inline-flex items-center justify-center rounded-md ..."
```

## Card Component

```ruby
class CardComponent < UIComponent
  private
  
  def base_style
    Tailwindcss::Style.new(
      bg: :white,
      rounded: :lg,
      overflow: :hidden,
      **dark(bg: :gray_800)
    )
  end
  
  def variant_style
    case options[:variant]
    when :elevated
      {
        shadow: :xl,
        _hover: { shadow: "2xl" },
        transition: :shadow
      }
    when :outlined
      {
        border: true,
        border_gray: 200,
        **dark(border_gray: 700)
      }
    else
      { shadow: :md }
    end
  end
  
  def size_style
    case options[:size]
    when :sm
      { p: 4 }
    when :lg
      { p: 8 }
    else
      { p: 6 }
    end
  end
end

class CardHeader < UIComponent
  private
  
  def base_style
    Tailwindcss::Style.new(
      border_b: true,
      border_gray: 200,
      pb: 4,
      mb: 4,
      **dark(border_gray: 700)
    )
  end
end

class CardTitle < UIComponent
  private
  
  def base_style
    Tailwindcss::Style.new(
      text: :xl,
      font: :semibold,
      text_gray: 900,
      **dark(text_gray: 100)
    )
  end
end
```

## Form Components

```ruby
class FormField < UIComponent
  private
  
  def base_style
    Tailwindcss::Style.new(mb: 4)
  end
end

class FormLabel < UIComponent
  private
  
  def base_style
    Tailwindcss::Style.new(
      block: true,
      text: :sm,
      font: :medium,
      text_gray: 700,
      mb: 1,
      **dark(text_gray: 300)
    )
  end
end

class FormInput < UIComponent
  STATES = {
    default: {
      border_gray: 300,
      _focus: {
        border_blue: 500,
        ring: 1,
        ring_blue: 500,
        outline: :none
      }
    },
    error: {
      border_red: 500,
      text_red: 900,
      placeholder_red: 300,
      _focus: {
        border_red: 500,
        ring: 1,
        ring_red: 500,
        outline: :none
      }
    },
    success: {
      border_green: 500,
      _focus: {
        border_green: 500,
        ring: 1,
        ring_green: 500,
        outline: :none
      }
    }
  }.freeze
  
  private
  
  def base_style
    Tailwindcss::Style.new(
      block: true,
      w: :full,
      px: 3,
      py: 2,
      rounded: :md,
      border: true,
      text: :base,
      shadow: :sm,
      transition: :colors,
      **dark(
        bg: :gray_700,
        border_gray: 600,
        text: :white
      )
    )
  end
  
  def state_style
    STATES[options[:state] || :default]
  end
  
  def size_style
    case options[:size]
    when :sm
      { px: 2, py: 1, text: :sm }
    when :lg
      { px: 4, py: 3, text: :lg }
    else
      {}
    end
  end
end

class FormHelperText < UIComponent
  private
  
  def base_style
    Tailwindcss::Style.new(
      mt: 1,
      text: :sm
    )
  end
  
  def state_style
    case options[:state]
    when :error
      { text_red: 600 }
    when :success
      { text_green: 600 }
    else
      { text_gray: 500 }
    end
  end
end
```

## Alert Component

```ruby
class AlertComponent < UIComponent
  VARIANTS = {
    info: {
      bg: :blue_50,
      border_blue: 400,
      text_blue: 800,
      **dark(
        bg: :blue_900,
        border_blue: 600,
        text_blue: 200
      )
    },
    success: {
      bg: :green_50,
      border_green: 400,
      text_green: 800,
      **dark(
        bg: :green_900,
        border_green: 600,
        text_green: 200
      )
    },
    warning: {
      bg: :yellow_50,
      border_yellow: 400,
      text_yellow: 800,
      **dark(
        bg: :yellow_900,
        border_yellow: 600,
        text_yellow: 200
      )
    },
    error: {
      bg: :red_50,
      border_red: 400,
      text_red: 800,
      **dark(
        bg: :red_900,
        border_red: 600,
        text_red: 200
      )
    }
  }.freeze
  
  private
  
  def base_style
    Tailwindcss::Style.new(
      p: 4,
      rounded: :lg,
      border_l: 4,
      mb: 4
    )
  end
  
  def variant_style
    VARIANTS[options[:variant] || :info]
  end
  
  def state_style
    return {} unless options[:dismissible]
    
    { relative: true, pr: 12 }
  end
end

class AlertTitle < UIComponent
  private
  
  def base_style
    Tailwindcss::Style.new(
      font: :semibold,
      mb: 1
    )
  end
end

class AlertDescription < UIComponent
  private
  
  def base_style
    Tailwindcss::Style.new(
      text: :sm
    )
  end
end
```

## Usage in Views

### ERB Templates

```erb
<%= content_tag :button, 
    class: ButtonComponent.new(variant: :primary, size: :lg) do %>
  Click me
<% end %>

<%= content_tag :div, class: CardComponent.new(variant: :elevated) do %>
  <%= content_tag :div, class: CardHeader.new do %>
    <%= content_tag :h2, "Card Title", class: CardTitle.new %>
  <% end %>
  <p>Card content goes here</p>
<% end %>

<%= content_tag :div, class: AlertComponent.new(variant: :success) do %>
  <%= content_tag :h3, "Success!", class: AlertTitle.new %>
  <%= content_tag :p, "Operation completed.", class: AlertDescription.new %>
<% end %>
```

### Rails Helpers

```ruby
module ComponentsHelper
  def ui_button(text, **options, &block)
    content_tag :button, 
                class: ButtonComponent.new(**options) do
      text || capture(&block)
    end
  end
  
  def ui_card(**options, &block)
    content_tag :div, 
                class: CardComponent.new(**options), 
                &block
  end
  
  def ui_alert(variant: :info, **options, &block)
    content_tag :div,
                class: AlertComponent.new(variant: variant, **options),
                &block
  end
  
  def ui_form_field(&block)
    content_tag :div, class: FormField.new, &block
  end
  
  def ui_form_input(type: :text, **options)
    tag :input,
        type: type,
        class: FormInput.new(**options)
  end
end
```

### Usage with Helpers

```erb
<%= ui_button "Save", variant: :primary, size: :lg %>

<%= ui_card variant: :elevated do %>
  <h2>Welcome</h2>
  <p>This is a card component</p>
<% end %>

<%= ui_alert variant: :success do %>
  Your changes have been saved!
<% end %>

<%= ui_form_field do %>
  <label class="<%= FormLabel.new %>">Email</label>
  <%= ui_form_input type: :email, state: :error %>
  <p class="<%= FormHelperText.new(state: :error) %>">
    Invalid email address
  </p>
<% end %>
```

## Best Practices

1. **Keep components focused**: Each component should have a single responsibility
2. **Use composition**: Build complex components from simpler ones
3. **Make them configurable**: Use options for variants, sizes, and states
4. **Provide sensible defaults**: Components should work with minimal configuration
5. **Document usage**: Include examples in your component files
6. **Test your components**: Write specs for style generation