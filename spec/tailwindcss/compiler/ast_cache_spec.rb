# frozen_string_literal: true

require "tailwindcss/compiler/ast_cache"
require "tempfile"
require "fileutils"

RSpec.describe Tailwindcss::Compiler::AstCache do
  let(:cache_dir) { Dir.mktmpdir }
  let(:cache) { described_class.new(cache_dir: cache_dir) }
  let(:test_file) { Tempfile.new(["test", ".rb"], cache_dir) }

  after do
    test_file.close
    test_file.unlink
    FileUtils.rm_rf(cache_dir)
  end

  describe "#fetch" do
    context "when the file is not cached" do
      it "yields to the block and stores the result" do
        test_classes = %w[bg-red text-white]

        result = cache.fetch(test_file.path) do
          test_classes
        end

        expect(result).to eq(test_classes)

        # Verify it was stored
        cached_result = cache.fetch(test_file.path) { raise "Should not yield" }
        expect(cached_result).to eq(test_classes)
      end
    end

    context "when the file is cached and not stale" do
      it "returns the cached value without yielding" do
        test_classes = %w[bg-blue p-4]

        # First call stores it
        cache.fetch(test_file.path) { test_classes }

        # Second call should use cache
        result = cache.fetch(test_file.path) do
          raise "Should not yield to block"
        end

        expect(result).to eq(test_classes)
      end
    end

    context "when the cached file is stale" do
      it "yields to the block and updates the cache" do
        old_classes = ["bg-red"]
        new_classes = %w[bg-blue mt-4]

        # Store initial cache
        cache.fetch(test_file.path) { old_classes }

        # Modify the file to make cache stale
        sleep(0.01) # Ensure mtime is different
        test_file.write("# modified")
        test_file.flush

        # Should fetch new value
        result = cache.fetch(test_file.path) { new_classes }

        expect(result).to eq(new_classes)
      end
    end

    context "when the file doesn't exist" do
      it "yields to the block" do
        non_existent_path = File.join(cache_dir, "non_existent.rb")
        test_classes = %w[flex items-center]

        result = cache.fetch(non_existent_path) { test_classes }

        expect(result).to eq(test_classes)
      end
    end
  end

  describe "#clear" do
    it "removes all cached entries" do
      test_classes = %w[bg-white shadow]

      # Store something in cache
      cache.fetch(test_file.path) { test_classes }

      # Clear the cache
      cache.clear

      # Should yield to block again
      yielded = false
      cache.fetch(test_file.path) do
        yielded = true
        test_classes
      end

      expect(yielded).to be true
    end
  end

  describe "persistence" do
    it "persists cache between instances" do
      test_classes = %w[grid gap-4]

      # First instance stores cache
      cache1 = described_class.new(cache_dir: cache_dir)
      cache1.fetch(test_file.path) { test_classes }

      # Second instance should load from disk
      cache2 = described_class.new(cache_dir: cache_dir)
      result = cache2.fetch(test_file.path) { raise "Should not yield" }

      expect(result).to eq(test_classes)
    end

    it "handles corrupted cache files gracefully" do
      cache_file = File.join(cache_dir, "ast_cache.json")
      FileUtils.mkdir_p(cache_dir)
      File.write(cache_file, "invalid json {{{")

      # Should handle the error and start fresh
      cache = described_class.new(cache_dir: cache_dir)
      test_classes = %w[border rounded]

      result = cache.fetch(test_file.path) { test_classes }

      expect(result).to eq(test_classes)
    end
  end

  describe "cache pruning" do
    it "limits cache size to prevent unbounded growth" do
      # This is tested indirectly through the private prune_old_entries method
      # The cache should automatically prune when it exceeds 500 entries

      cache_file = File.join(cache_dir, "ast_cache.json")

      # Create a cache with many entries (501 to trigger pruning at 500)
      501.times do |i|
        file_path = File.join(cache_dir, "file_#{i}.rb")
        cache.fetch(file_path) { ["class-#{i}"] }
      end

      # Load the cache file and check size
      cache_data = JSON.parse(File.read(cache_file))

      # Should have pruned to 250 entries (as per implementation)
      expect(cache_data.size).to be <= 250
    end
  end
end
