# GracefulShutdown

A tiny helper for handling signals and shutting down your program
safely.

This is is the outcome of a series of blog posts [about signal
handling in Ruby][blog]. If you understand the basic techniques involved, you
can probably write this library yourself, but it might save you a bit of
time. The tests for this library might be of interest to anyone testing
signal handlers using RSpec.

[blog]:http://timuruski.net/graceful-shutdown/


## Usage

There is a top-level method for handling signals, which wraps a block of
code. Anything running inside the block can rescue a `Shutdown`
exception and perform any necessary steps for a safe shutdown. Once
handled, the `continue` method can be called to re-raise the exception
and continue the shutdown.


```ruby
class Worker < Struct.new(:jobs_queue)
  def work
    job = jobs_queue.pop
    # work...
  rescue Shutdown => shutdown
    jobs_queue.push job if job.incomplete?
    shutdown.continue
  end
end

require 'graceful_shutdown'

WithGracefulShutdown do
  jobs = Queue.new
  Worker.new(jobs).start
end
```

As the blog posts continue, there will likely be some enhancements to
this gem.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Copyright

Copyright 2014 Tim Uruski – Released under [MIT
License](http://timuruski.mit-license.org)
