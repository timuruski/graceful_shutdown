# This manages a standalone Ruby subprocess for us.
# We can't use fork, because RSpec's own signal handlers interfere
# with the signals we are testing.
class RubyProcess
  # Top-level method to signal readiness to the parent process and
  # then wait for interrupt.
  WAIT_HELPER = <<-EOS
    def wait_for_interrupt(seconds)
      # Signal parent we are ready.
      Process.kill('USR1', Process.ppid)

      # Wait for interrupt.
      sleep(seconds)
    end
  EOS
  def initialize(code, *args)
    cmd = ['ruby'] + args
    @io = IO.popen(cmd, 'w+', err: [:child, :out])
    @io.write(WAIT_HELPER)
    @io.write(code)
  end

  attr_reader :io, :pid

  def run_and_send(signal)
    # Using the USR1 signal here to detect when the program is ready to
    # receive a test signal. I'd prefer not to use trap here, but the
    # exit status gets clobbered, presumably because the USR1 signal
    # gets converted into an exception in the child process.
    usr1_handler = trap('USR1') do
      Process.kill(signal, io.pid)
    end

    # The program starts when the write end of the pipe is closed.
    io.close_write
    @pid, @status = Process.waitpid2(io.pid)
  ensure
    trap('USR1', usr1_handler)
  end

  def status
    @status.to_i
  end

  def output
    io.read
  end
end
