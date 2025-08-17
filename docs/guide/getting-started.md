# Getting Started

## Introduction

tailwindcss-rb is a Ruby gem that provides a Ruby-like library and compiler for Tailwind CSS. Its goal is to serve as an atomic set of functions that help you build your own UI framework in Ruby.

## What makes it special?

- **Ruby-native API**: Write Tailwind classes using Ruby hashes and symbols
- **Smart compilation**: Only compiles the classes you actually use
- **Component-friendly**: Build reusable UI components with Ruby patterns
- **Rails integration**: Seamlessly integrates with Rails asset pipeline
- **Performance optimized**: Intelligent caching and incremental compilation

## Prerequisites

Before you begin, ensure you have:

- Ruby 2.6.0 or higher
- Rails application (optional but recommended)
- Node.js and npm (for Tailwind CSS compilation)
- Basic understanding of Tailwind CSS

## Quick Start

### 1. Add to your Gemfile

```ruby
gem 'tailwindcss-rb'
```

### 2. Install the gem

```bash
bundle install
```

### 3. Run the installer

```bash
bundle exec rake tailwindcss:install
```

### 4. Start using in your views

```erb
<%= content_tag :div, class: tailwind(bg: :blue, text: :white, p: 4) do %>
  Hello, Tailwind!
<% end %>
```

## What's Next?

- Learn about [Installation](./installation) options and configuration
- Explore [Basic Usage](./basic-usage) patterns
- Configure your setup in [Configuration](./configuration)
- Build components with [Style Composition](./style-composition)