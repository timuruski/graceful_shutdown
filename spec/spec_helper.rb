$LOAD_PATH.unshift File.expand_path('../lib')

require 'rspec'
require 'ruby_block'

RSpec.configure do |conf|
  conf.formatter = 'documentation'
  conf.color = true
  conf.order = 'random'
end
