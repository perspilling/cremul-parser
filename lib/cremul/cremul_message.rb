require_relative 'cremul_header'
require_relative 'cremul_line'
require_relative 'parser_helper'

class CremulMessage
  include Cremul::ParserHelper

  # The message_index is the index number of the Cremul message in the file.
  attr_reader :message_index, :header, :number_of_lines, :lines

  def initialize(message_number, segments)
    @message_index = message_number
    @header = CremulHeader.new(segments)
    @lines = []
    @number_of_lines = number_of_lines_in_message(segments)

    # instantiate the line items
    line_segment_pos = next_line_segment_index(segments, 0)
    @number_of_lines.times do |n|
      CremulParser.logger.info "CremulParser: file=#{CremulParser.filename}, parsing line #{n+1}"
      @lines << CremulLine.new(n+1, segments, line_segment_pos)
      line_segment_pos = next_line_segment_index(segments, line_segment_pos+1)
    end

  end
end