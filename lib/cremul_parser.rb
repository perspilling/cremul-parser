# encoding: UTF-8

require_relative 'cremul/parser_helper'
require_relative 'cremul/cremul_message'

class CremulParser
  include Cremul::ParserHelper

  attr_reader :segments, :msg

  def initialize
  end

  def parse(file)
    file_as_a_string = ''
    file.each do |line|
      line.encode(Encoding::UTF_8)
      file_as_a_string += line.chop
    end
    @segments = file_as_a_string.split("'")
    @msg = CremulMessage.new(@segments)
  end

end
