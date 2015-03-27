# cremul-parser gem

This is a simple parser for CREMUL payment transaction files written in Ruby. It parses
the CREMUL file and creates a Ruby object structure corresponding to the elements in the file.

The parser is currently not a complete parser for all kinds of CREMUl files, but is 
being developed further as needed in an ongoing project for a Norwegian customer. 

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

```
require 'cremul_parser'

f = File.open(<CREMUL-file>)
parser = CremulParser.new
parser.parse(f)
f.close
```

or if the file is not utf-8 encoded

```
f = File.open(<CREMUL-file>)
parser = CremulParser.new
parser.parse(f, <encoding>) # for instance 'ISO-8859-1'
f.close
```

A file may contain one or more Cremul messages. A Cremul message consists of 'message segments'.
Each segment starts with a Cremul keyword. A group of segments make up a logical element of the
Cremul message. The overall logical structure of a Cremul file is as follows:

```
 [ Cremul file ] 1 --- * [ Cremul message ] 1 --- * [ Line ] 1 --- * [ Payment TX ]
```

See the `parser_test.rb` file for more details.

## Copyright

Copyright (c) 2014 Per Spilling (per@kodemaker.no). See LICENSE.txt for details.
