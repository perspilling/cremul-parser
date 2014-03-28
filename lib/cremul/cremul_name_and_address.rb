require_relative 'parser_helper'

class CremulNameAndAddress
  include Cremul::ParserHelper

  # NAD+party-id+code+code+nad-line1+nad-line2+nad-line3+nad-line4+nad-line5

  attr_reader :type, :nad_lines

  def initialize(nad_segment)
    s = nad_segment.split('+')
    @type = s[1].to_sym

    @nad_lines = []
    5.times do |i|
      @nad_lines << s[i+4]
    end

  end
end