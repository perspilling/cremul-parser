# cremul-parser gem

This is a simple parser for CREMUL payment transaction files written in Ruby. It parses
the CREMUL file (which should be in UTF-8 encoding) and creates a Ruby object structure
corresponding to the elements in the file.

## References

Here are som useful references regarding the CREMUL file format:

1. [CREMUL documentation from bsk.no](http://bsk.no/hovedmeny/gjeldende-standarder.aspx)
2. [CREMUL documentation from truugo.com](http://www.truugo.com/edifact/d12b/cremul/)

## Installation

Add this line to your application's Gemfile:

    gem 'cremul-parser'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cremul-parser

## Usage

See the `parser_test.rb` file.

## Copyright

Copyright (c) 2014 Per Spilling (per@kodemaker.no). See LICENSE.txt for details.
