# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adam6050/version'

Gem::Specification.new do |spec|
  spec.name          = 'adam6050'
  spec.version       = ADAM6050::VERSION
  spec.authors       = ['Sebastian Lindberg']
  spec.email         = ['seb.lindberg@gmail.com']

  spec.summary       = 'Server implementation of the ADAM-6050 IO module.'
  spec.description   = 'This library implements a server that emulates the ' \ 
                       'functionality of the network connected Advantech ' \ 
                       'ADAM-6050 digital IO module. Specifically the UDP ' \ 
                       'protocol that the unit speaks has been reverse ' \ 
                       "engineered. Since I don't have an actual device to " \ 
                       'test with the response messages from the server may ' \ 
                       'differ from what they should be. It all works well ' \ 
                       'enough for interfacing with Synology Surveillance ' \ 
                       'Station which is the original intent.'
  spec.homepage      = 'https://github.com/seblindberg/ruby-adam6050'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0")
                     .reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'redcarpet', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'yard', '~> 0.9'
end
