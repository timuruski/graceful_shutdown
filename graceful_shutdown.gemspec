# -*- encoding: utf-8 -*-
# Hi, mom!

Gem::Specification.new do |gem|
  gem.name        = 'graceful_shutdown'
  gem.version     = '1.0.0'
  gem.platform    = Gem::Platform::RUBY
  gem.license     = 'MIT'
  gem.author      = 'Tim Uruski'
  gem.email       = 'nerd@timuruski.net'
  gem.date        = '2014-05-24'
  gem.summary     = 'A tiny helper for handling signals.'
  gem.description = 'You can use GracefulShutdown to catch signals and safely shutdown your program.'
  gem.homepage    = 'https://rubygemgem.org/graceful_shutdown'

  gem.files       = ['lib/graceful_shutdown.rb']
  gem.test_files  = gem.files.grep(/spec\//)

  gem.add_development_dependency 'rspec', '~> 3.0'
end
