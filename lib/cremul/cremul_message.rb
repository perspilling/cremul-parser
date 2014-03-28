require_relative 'cremul_header'
require_relative 'cremul_line'
require_relative 'parser_helper'

class CremulMessage
  include Cremul::ParserHelper

  attr_reader :header, :number_of_lines, :lines

  def initialize(segments)
    @header = CremulHeader.new(segments)
    @lines = []
    @number_of_lines = number_of_lines_in_message(segments)

    # instantiate the line items
    line_segment_pos = next_line_segment_index(segments, 0)
    @number_of_lines.times do
      @lines << CremulLine.new(segments, line_segment_pos)
      line_segment_pos = next_line_segment_index(segments, line_segment_pos+1)
    end

  end
end