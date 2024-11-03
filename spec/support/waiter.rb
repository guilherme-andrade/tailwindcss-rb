module Waiter
  extend self

  def wait_until(timeout:, &block)
    Timeout.timeout(timeout) do
      loop do
        begin
          break if block.call
        rescue StandardError
          next
        end
      end
    end
  end
end
