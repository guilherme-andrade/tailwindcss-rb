---
layout: home

hero:
  name: tailwindcss-rb
  text: Ruby-powered Tailwind CSS
  tagline: Build your own UI framework in Ruby with the power of Tailwind CSS
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: View on GitHub
      link: https://github.com/guilherme-andrade/tailwindcss-rb

features:
  - icon: 💎
    title: Ruby-like API
    details: Write Tailwind classes using intuitive Ruby syntax with hash arguments and method chaining
  - icon: ⚡
    title: Smart Compilation
    details: Automatically extracts and compiles only the classes you use, with intelligent caching
  - icon: 🎨
    title: Style Composition
    details: Compose, merge, and reuse styles with powerful Ruby patterns for maintainable component design
  - icon: 🌙
    title: Dark Mode Support
    details: Built-in helpers for dark mode with clean, readable syntax using the dark() helper
  - icon: 📱
    title: Responsive Design
    details: Elegant responsive breakpoints using the at() helper for mobile-first development
  - icon: 🚀
    title: Production Ready
    details: Optimized for Rails with support for CDN deployment, Heroku, and asset pipeline integration
---

## Quick Example

```ruby
include Tailwindcss::Helpers

# Simple usage
tailwind(bg: :blue, text: :white, p: 4, rounded: :lg)
# => "bg-blue-500 text-white p-4 rounded-lg"

# Dark mode and responsive
tailwind(
  bg: :white,
  text: :black,
  **dark(bg: :gray_900, text: :white),
  **at(:md, p: 6),
  **at(:lg, p: 8)
)
# => "bg-white text-black dark:bg-gray-900 dark:text-white md:p-6 lg:p-8"

# Component composition
button_base = Tailwindcss::Style.new(px: 4, py: 2, rounded: :md)
primary_button = button_base.merge(bg: :blue, text: :white)
```

## Why tailwindcss-rb?

Traditional Tailwind CSS in Rails views can become verbose and hard to maintain:

```erb
<!-- Traditional approach -->
<div class="bg-white dark:bg-gray-900 p-4 md:p-6 lg:p-8 rounded-lg shadow-xl hover:shadow-2xl transition-shadow">
  <!-- content -->
</div>
```

With tailwindcss-rb, you get a clean, composable Ruby API:

```erb
<!-- tailwindcss-rb approach -->
<div class="<%= card_style %>">
  <!-- content -->
</div>
```

```ruby
def card_style
  tailwind(
    bg: :white,
    p: { base: 4, md: 6, lg: 8 },
    rounded: :lg,
    shadow: :xl,
    **dark(bg: :gray_900),
    _hover: { shadow: "2xl" },
    transition: :shadow
  )
end
```

## Ready to dive in?

<div style="display: flex; gap: 1rem; margin-top: 2rem;">
  <a href="/guide/getting-started" style="display: inline-block; padding: 0.75rem 1.5rem; background: #3b82f6; color: white; text-decoration: none; border-radius: 0.5rem; font-weight: 500;">
    Get Started →
  </a>
  <a href="/examples/components" style="display: inline-block; padding: 0.75rem 1.5rem; background: #f3f4f6; color: #1f2937; text-decoration: none; border-radius: 0.5rem; font-weight: 500;">
    View Examples
  </a>
</div>