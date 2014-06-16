class RubyBlock
  def initialize(&test_block)
    @test_block = test_block
  end

  def wait_for_signal(seconds)
    @sync_wr.puts 'READY'
    @sync_wr.flush
    sleep(seconds)
  end

  def run_and_send(signal)
    sync_rd, @sync_wr = IO.pipe
    output_rd, output_wr = IO.pipe

    pid = fork do
      $stdout = $stderr = output_wr
      @test_block.call(self)
    end

    sync_rd.gets
    Process.kill(signal, pid)
    _, @status = Process.waitpid2(pid)

    output_wr.close
    @output = output_rd.read

    self
  ensure
    close_all(sync_rd, @sync_wr, output_rd, output_wr)
  end

  def successful?
    @status && @status.success?
  end

  def output
    @output
  end

  def close_all(*pipes)
    pipes.each do |pipe|
      pipe.close unless pipe.closed?
    end
  end
end
