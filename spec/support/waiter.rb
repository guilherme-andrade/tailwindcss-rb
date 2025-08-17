# frozen_string_literal: true

module Waiter
  module_function

  def wait_until(timeout:, &block)
    Timeout.timeout(timeout) do
      loop do
        break if block.call
      rescue
        next
      end
    end
  end
end
