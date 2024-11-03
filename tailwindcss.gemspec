# frozen_string_literal: true

require_relative "lib/tailwindcss/version"

Gem::Specification.new do |spec|
  spec.name = "tailwindcss-rb"
  spec.version = Tailwindcss::VERSION
  spec.authors = ["guilherme-andrade"]
  spec.email = ["inbox@guilherme-andrade.com"]

  spec.summary = "A Ruby wrapper for Tailwind CSS"
  spec.description = "A Ruby wrapper for Tailwind CSS"
  spec.homepage = "https://guilherme-andrade.com/tailwindcss"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/guilherme-andrade/tailwindcss"
  spec.metadata["changelog_uri"] = "https://github.com/guilherme-andrade/tailwindcss/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "listen"
  spec.add_dependency "dry-configurable", "~> 1.0"
  spec.add_dependency "deep_merge", "~> 1.0"
  spec.add_dependency "activesupport", "~> 7.0"
end
