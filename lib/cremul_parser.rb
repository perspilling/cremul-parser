# encoding: UTF-8

require_relative 'cremul/parser_helper'
require_relative 'cremul/cremul_message'

class CremulParser
  include Cremul::ParserHelper

  attr_reader :segments, :msg

  def initialize
  end

  def parse(file, file_encoding='utf-8')
    file_as_a_string = ''
    file.each do |line|
      unless file_encoding == 'utf-8'
        line = line.encode('utf-8', file_encoding)
      end
      file_as_a_string += line.chomp # remove \n and \r from the end of the line
    end
    @segments = file_as_a_string.split("'")
    if @segments[@segments.size-1].strip.empty?
      @segments = @segments.slice(0, @segments.size-1)
    end
    @msg = CremulMessage.new(@segments)
  end

end
