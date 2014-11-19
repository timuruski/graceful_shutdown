# Executes a block of code, translating signals into a Shutdown
# exception that can be rescued to signal safe shutdown.
#
# ## Example:
#
#     WithGracefulShutdown do
#       begin
#         loop do
#           print '.'
#           sleep 0.5
#         end
#       rescue Shutdown => shutdown
#         puts "\ngoodbye"
#         shutdown.continue
#       end
#     end
#
# @param [String] *signals Names of signals to handle.
# @param [Proc] &block Block of code to run while handling signals.
def WithGracefulShutdown(*signals, &block)
  GracefulShutdown.new.handle_signals(*signals, &block)
end

class Shutdown < RuntimeError
  # Re-raises the exception, continuing shutdown.
  def continue
    raise self
  end

  # No-Op, provides clarity that shutdown is being ignored.
  def ignore
    # No-Op, provided for clarity.
  end
end

class GracefulShutdown
  VERSION = '1.0.0'

  DEFAULT_SIGNALS = ['INT', 'TERM']
  HANDLER = proc { raise Shutdown }

  # Executes a block of code, translating signals into a Shutdown
  # exception that can be rescued to signal safe shutdown.
  #
  # @param [String] *signals Names of signals to handle.
  # @param [Proc] &block Block of code to run while handling signals.
  def handle_signals(*signals, &block)
    signals = DEFAULT_SIGNALS if signals.empty?

    handlers = setup(signals)
    yield if block_given?
    teardown(handlers)
  rescue Shutdown
    exit
  end

  private

  # Setup signal traps, keeping track of the original handlers.
  # NOTE If something else below this sets a trap, these traps will not
  # be invoked.
  def setup(signals)
    signals.each_with_object({}) do |signal, handlers|
      handlers[signal] = trap(signal, HANDLER)
    end
  end

  # Restore original signal handlers.
  def teardown(handlers)
    handlers.each do |signal, handler|
      trap(signal, handler)
    end
  end
end
