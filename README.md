# 🎛 ADAM6050

[![Gem Version](https://badge.fury.io/rb/adam6050.svg)](https://badge.fury.io/rb/vissen-input)
[![Build Status](https://travis-ci.org/seblindberg/ruby-adam6050.svg?branch=master)](https://travis-ci.org/seblindberg/ruby-adam6050)
[![Inline docs](http://inch-ci.org/github/seblindberg/ruby-adam6050.svg?branch=master)](http://inch-ci.org/github/seblindberg/ruby-adam6050)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/adam6050/)

This library implements a server that emulates the functionality of the network connected Advantech ADAM-6050 IO module.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adam6050'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adam6050

## Usage

```ruby
require 'adam6050'

server = ADAM6050::Server.new
server.run do |state, prev_state|
    # React to the new state
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seblindberg/ruby-adam6050.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
