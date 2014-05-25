require 'spec_helper'
require 'graceful_shutdown'

describe GracefulShutdown do
  def ruby_proc(code)
   RubyProcess.new(code, '-r./lib/graceful_shutdown')
  end

  it "exits without error" do
    ruby = ruby_proc <<-EOS
      GracefulShutdown.new.handle_signals do
        wait_for_interrupt 1.0
        raise 'No Interrupt received'
      end
    EOS

    ruby.run_and_send('INT')

    expect(ruby).to exit_without_error
  end

  it "raises a Shutdown exception" do
    ruby = ruby_proc <<-EOS
      GracefulShutdown.new.handle_signals do
        begin
          wait_for_interrupt 1.0
        rescue Shutdown
          puts 'shutdown received'
          exit
        else
          raise 'No Interrupt received'
        end
      end
    EOS

    ruby.run_and_send('INT')

    expect(ruby).to exit_without_error
    expect(ruby.output).to match(/shutdown received/)
  end

  it "catches the Shutdown" do
    ruby = ruby_proc <<-EOS
      GracefulShutdown.new.handle_signals do
        begin
          wait_for_interrupt 1.0
        rescue Shutdown => shutdown
          raise shutdown
        else
          raise 'No Interrupt received'
        end
      end
    EOS

    ruby.run_and_send('INT')

    expect(ruby).to exit_without_error
  end

  it "restores existing signal handlers" do
    ruby = ruby_proc <<-EOS
      trap('INT') do
        puts 'default interrupt'
        exit
      end

      GracefulShutdown.new.handle_signals do
        # work
      end

      wait_for_interrupt 1.0
    EOS

    ruby.run_and_send('INT')

    expect(ruby).to exit_without_error
    expect(ruby.output).to match(/default interrupt/)
  end

  it "handles signals other than interrupt" do
    ruby = ruby_proc <<-EOS
      GracefulShutdown.new.handle_signals('USR2') do
        wait_for_interrupt 1.0
        raise 'No Interrupt received'
      end
    EOS

    ruby.run_and_send('USR2')

    expect(ruby).to exit_without_error
  end
end
