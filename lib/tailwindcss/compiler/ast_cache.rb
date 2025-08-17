# frozen_string_literal: true

require "json"
require "fileutils"

module Tailwindcss
  module Compiler
    class AstCache
      def initialize(cache_dir: nil)
        @cache_dir = cache_dir || default_cache_dir
        @cache_file = File.join(@cache_dir, "ast_cache.json")
        @cache = load_cache
      end

      def fetch(file_path)
        if cached?(file_path) && !stale?(file_path)
          @cache[file_path]["classes"]
        else
          classes = yield
          store(file_path, classes) if classes
          classes
        end
      end

      def clear
        @cache = {}
        save_cache
      end

      private

      def default_cache_dir
        dir = Tailwindcss.config.compiler.compile_classes_dir
        dir.respond_to?(:call) ? dir.call : dir
      end

      def load_cache
        return {} unless File.exist?(@cache_file)

        JSON.parse(File.read(@cache_file))
      rescue JSON::ParserError => e
        Tailwindcss.logger.warn "Failed to load AST cache: #{e.message}. Starting fresh."
        {}
      end

      def save_cache
        FileUtils.mkdir_p(@cache_dir)

        # Limit cache size to prevent unbounded growth
        prune_old_entries if @cache.size > 500

        File.write(@cache_file, JSON.pretty_generate(@cache))
      rescue => e
        Tailwindcss.logger.error "Failed to save AST cache: #{e.message}"
      end

      def cached?(file_path)
        @cache.key?(file_path)
      end

      def stale?(file_path)
        return true unless File.exist?(file_path)

        cached_mtime = @cache[file_path]["mtime"]
        current_mtime = File.mtime(file_path).to_f

        current_mtime > cached_mtime
      end

      def store(file_path, classes)
        mtime = File.exist?(file_path) ? File.mtime(file_path).to_f : Time.now.to_f

        @cache[file_path] = {
          "classes" => classes,
          "mtime" => mtime,
          "accessed_at" => Time.now.to_f
        }
        save_cache
      end

      def prune_old_entries
        # Remove least recently accessed entries
        sorted_entries = @cache.sort_by { |_, data| data["accessed_at"] || 0 }
        @cache = sorted_entries.last(250).to_h
      end
    end
  end
end
