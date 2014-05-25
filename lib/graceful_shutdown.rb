# Catches +INT+ and +TERM+ and allows the task/program to finish execution
# before handling the interrupt safely.
#
# Usage:
#   WithGracefulShutdown do
#     begin
#       loop do
#         print '.'
#         sleep 0.5
#       end
#     rescue Shutdown => shutdown
#       puts "\ngoodbye"
#       shutdown.continue
#     end
#   end

def WithGracefulShutdown(*signals, &block)
  GracefulShutdown.new.handle_signals(*signals, &block)
end

class Shutdown < RuntimeError
  def continue
    raise self
  end

  def ignore
    # No-Op, provided for clarity.
  end
end

class GracefulShutdown
  DEFAULT_SIGNALS = ['INT', 'TERM']
  HANDLER = proc { raise Shutdown }

  # Execute a block of code with signal handlers.
  def handle_signals(*signals)
    signals = DEFAULT_SIGNALS if signals.empty?

    handlers = setup(signals)
    yield if block_given?
    teardown(handlers)
  rescue Shutdown
    teardown(handlers)
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
