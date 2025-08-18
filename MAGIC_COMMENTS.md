# Magic Comments for Tailwind Class Extraction

The tailwindcss-rb gem supports magic comments to explicitly whitelist Tailwind CSS classes that should be included in the final CSS. This is useful when you have dynamic class generation that can't be automatically detected by static analysis.

## Usage

Use the `@tw-whitelist` directive in comments to declare classes:

```ruby
class ButtonComponent
  # @tw-whitelist bg-blue-500 bg-blue-600 hover:bg-blue-700 text-white
  # @tw-whitelist bg-red-500 bg-red-600 hover:bg-red-700
  
  def render
    # Dynamic class that might not be extracted
    "bg-#{color}-500"
  end
end
```

## Syntax

The basic syntax is:
```ruby
# @tw-whitelist class1 class2 class3
```

### Multiple Lines

You can use multiple `@tw-whitelist` comments:

```ruby
# @tw-whitelist bg-primary-500 bg-primary-600
# @tw-whitelist hover:bg-primary-700 text-white
# @tw-whitelist border-primary-500
```

### Inline with Code

Magic comments can be placed anywhere in your Ruby files:

```ruby
variant :solid,
  # @tw-whitelist bg-primary-50 bg-primary-100
  bg: proc { dynamic_color_method(500) }
```

### In ERB Files

For ERB templates, you can use both Ruby comments and HTML comments:

```erb
<!-- @tw-whitelist mx-auto container max-w-7xl -->
<div class="<%= dynamic_classes %>">
  <% # @tw-whitelist px-4 py-2 sm:px-6 lg:px-8 %>
  <%= content %>
</div>
```

## Use Cases

### Dynamic Color Schemes

When using dynamic color generation methods:

```ruby
class ButtonComponent
  # Whitelist all color variations you might use
  # @tw-whitelist bg-primary-500 bg-primary-600 hover:bg-primary-700
  # @tw-whitelist bg-secondary-500 bg-secondary-600 hover:bg-secondary-700
  # @tw-whitelist bg-success-500 bg-danger-500 bg-warning-500
  
  def button_class
    "bg-#{@color_scheme}-500"  # Dynamic - won't be extracted automatically
  end
end
```

### Component Libraries

For component libraries with configurable props:

```ruby
module ViewComponentUI
  class ButtonComponent
    # Whitelist all possible variant combinations
    # @tw-whitelist bg-blue-50 bg-blue-100 bg-blue-500 bg-blue-600
    # @tw-whitelist text-blue-500 text-blue-600 border-blue-500
    # @tw-whitelist hover:bg-blue-500 hover:bg-blue-600
    
    variant :solid,
      bg: proc { props_color_scheme_token(500) }
  end
end
```

### Responsive Utilities

For responsive classes that might be conditionally applied:

```ruby
# @tw-whitelist sm:px-4 md:px-6 lg:px-8 xl:px-10
# @tw-whitelist sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4
```

### State Variants

For state-based classes:

```ruby
# @tw-whitelist disabled:opacity-50 disabled:cursor-not-allowed
# @tw-whitelist focus:ring-2 focus:ring-offset-2 focus:ring-blue-500
# @tw-whitelist active:scale-95 active:bg-blue-700
```

## How It Works

1. During extraction, the gem scans all files for `@tw-whitelist` comments
2. Classes listed in these comments are added to the `.classes` files
3. Tailwind CSS includes these classes when generating the final CSS
4. The comments don't affect your runtime code - they're purely for build-time extraction

## Best Practices

1. **Place comments near the relevant code** - This makes it clear why classes are being whitelisted
2. **Group related classes** - Use multiple lines to organize classes by feature or component
3. **Document dynamic patterns** - Explain why manual whitelisting is needed
4. **Use for edge cases only** - Most classes should be extracted automatically from your Ruby code

## Future Directives

The `@tw-` prefix is reserved for future Tailwind-related directives. Potential future additions:

- `@tw-ignore` - Exclude certain classes from extraction
- `@tw-layer` - Specify which Tailwind layer classes belong to
- `@tw-safelist` - Force inclusion even in production builds

## Example: ViewComponentUI

Here's a real-world example from a component library:

```ruby
module ViewComponentUI
  class ButtonComponent < BaseComponent
    # Whitelist all color scheme variations
    # @tw-whitelist bg-primary-50 bg-primary-100 bg-primary-500 bg-primary-600 bg-primary-700
    # @tw-whitelist bg-secondary-50 bg-secondary-100 bg-secondary-500 bg-secondary-600 bg-secondary-700
    # @tw-whitelist bg-success-500 bg-success-600 bg-danger-500 bg-danger-600
    # @tw-whitelist text-primary-500 text-primary-600 text-primary-700
    # @tw-whitelist border-primary-500 border-primary-600
    # @tw-whitelist hover:bg-primary-600 hover:bg-primary-700 hover:bg-primary-100
    
    default_props color_scheme: :primary
    
    variant :solid,
      bg: proc { props_color_scheme_token(500) },
      _hover: { bg: proc { props_color_scheme_token(600) } }
    
    variant :ghost,
      bg: proc { props_color_scheme_token(50) },
      color: proc { props_color_scheme_token(500) },
      _hover: { bg: proc { props_color_scheme_token(100) } }
  end
end
```

This ensures all color variations are included in the CSS, even though they're generated dynamically at runtime.