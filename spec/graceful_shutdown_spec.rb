require 'spec_helper'
require 'graceful_shutdown'

describe GracefulShutdown do
  it "exits without error" do
    test = RubyBlock.new do |helper|
      GracefulShutdown.new.handle_signals do
        helper.wait_for_signal 1.0
        raise 'No Interrupt received'
      end
    end

    test.run_and_send('INT')

    expect(test).to be_successful
  end

  it "raises a Shutdown exception" do
    test = RubyBlock.new do |helper|
      GracefulShutdown.new.handle_signals do
        begin
          helper.wait_for_signal 1.0
        rescue Shutdown
          puts 'shutdown received'
          exit
        else
          raise 'No Interrupt received'
        end
      end
    end

    test.run_and_send('INT')

    expect(test).to be_successful
    expect(test.output).to match(/shutdown received/)
  end

  it "catches the Shutdown" do
    test = RubyBlock.new do |helper|
      GracefulShutdown.new.handle_signals do
        begin
          helper.wait_for_signal 1.0
        rescue Shutdown => shutdown
          raise shutdown
        else
          raise 'No Interrupt received'
        end
      end
    end

    test.run_and_send('INT')

    expect(test).to be_successful
  end

  it "restores existing signal handlers" do
    test = RubyBlock.new do |helper|
      trap('INT') do
        puts 'default interrupt'
        exit
      end

      GracefulShutdown.new.handle_signals do
        # work
      end

      helper.wait_for_signal 1.0
    end

    test.run_and_send('INT')

    expect(test).to be_successful
    expect(test.output).to match(/default interrupt/)
  end

  it "handles signals other than interrupt" do
    test = RubyBlock.new do |helper|
      GracefulShutdown.new.handle_signals('USR2') do
        helper.wait_for_signal 1.0
        raise 'No Interrupt received'
      end
    end

    test.run_and_send('USR2')

    expect(test).to be_successful
  end
end
