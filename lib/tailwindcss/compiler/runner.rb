require "listen"
require "tailwindcss"
require "tailwindcss/compiler/file_classes_extractor"
require "tailwindcss/compiler/output"
require "tailwindcss/compiler/connection" if defined?(ActionCable)
require "tailwindcss/compiler/channel" if defined?(ActionCable)

module Tailwindcss
  module Compiler
    class Runner
      def initialize(watch: nil)
        @watch = watch
      end

      def call # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        output = Output.new
        file_classes_extractor = FileClassesExtractor.new

        content.each do |location|
          # Handle glob patterns vs directory paths
          location_str = location.to_s
          
          # Extract base directory for watching
          watch_dir = location_str.gsub(/\*.*$/, '').chomp('/')
          
          if watch || (watch.nil? && Tailwindcss.config.watch_content)
            if Dir.exist?(watch_dir)
              listener = Listen.to(watch_dir, only: /\.(rb|erb)$/) do |modified, added, removed|
                Tailwindcss.logger.info "Recompiling Tailwindcss..."
                Tailwindcss.logger.info "Modified: #{modified}"
                Tailwindcss.logger.info "Added: #{added}"
                Tailwindcss.logger.info "Removed: #{removed}"
                (modified + added + removed).compact.each do |file_path|
                  next unless File.file?(file_path)

                  classes = file_classes_extractor.call(file_path:)
                  next unless classes.present?

                  output.add_entry(file_path:, classes:)
                end

                Tailwindcss.compile_css!
              end

              listener.start
            end
          end

          # Use the glob pattern directly if it contains wildcards
          glob_pattern = if location_str.include?('*')
            location_str
          else
            # If it's a directory, add /**/* to get all files
            File.directory?(location_str) ? "#{location_str}/**/*" : location_str
          end
          
          Dir.glob(glob_pattern).each do |file_path|
            next unless File.file?(file_path)

            classes = file_classes_extractor.call(file_path:)
            next unless classes.present?

            output.add_entry(file_path:, classes:)
          end
        end

        Tailwindcss.compile_css!
      end

      private

      attr_reader :watch

      def content
        Tailwindcss.resolve_setting(Tailwindcss.config.content)
      end
    end
  end
end
