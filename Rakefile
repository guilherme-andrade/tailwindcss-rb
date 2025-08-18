# frozen_string_literal: true

require "bundler/gem_tasks"
require "bundler/setup"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

Dir.glob("lib/tasks/**/*.rake").each { |r| load r }
