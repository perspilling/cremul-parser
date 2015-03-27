# encoding: UTF-8

require_relative 'cremul/parser_helper'
require_relative 'cremul/cremul_message'


#
# A file may contain one or more Cremul messages. A Cremul message consists of 'message segments'.
# Each segment starts with a Cremul keyword. A group of segments make up a logical element of the
# Cremul message. The overall logical structure of a Cremul message is as follows:
#
# [ Cremul message ] 1 --- * [ Line ] 1 --- * [ Payment TX ]
#
class CremulParser
  include Cremul::ParserHelper

  attr_reader :segments, :messages

  def initialize
    @messages = []
  end

  # noinspection RubyResolve
  def parse(file, file_encoding='utf-8')
    file_as_a_string = ''
    file.each do |line|
      unless file_encoding == 'utf-8'
        line = line.encode('utf-8', file_encoding)
      end
      file_as_a_string += line.chomp # remove \n and \r from the end of the line
    end
    @segments = file_as_a_string.split("'")
    @segments.each { |s| s.strip! }
    # remove last segment if it is an empty string
    if @segments[@segments.size-1].empty?
      @segments = @segments.slice(0, @segments.size-1)
    end

    m = get_messages_in_file(@segments)
    if m.size == 0
      raise 'No CREMUL message found in file'
    end
    m.each do |n, start_index|
      if n < m.size
        @messages << CremulMessage.new(n, @segments[start_index, m[n+1] - start_index])
      else
        @messages << CremulMessage.new(n, @segments[start_index, @segments.size - start_index])
      end
    end
  end

end

