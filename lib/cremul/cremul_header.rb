require_relative 'parser_helper'
require 'date'

class CremulHeader
  include Cremul::ParserHelper

  # bf_id : Beneficiary ID. When the beneficiary is an organization this will be the organzation-number,
  #         and when the beneficiary is a person this will be the SSN, aka personnummer (NO).

  attr_reader :msg_id, :created_date, :bf_id

  # Expects an array with all segments in the CREMUL file
  def initialize(segments)
    @msg_id = segments[msg_id_segment_index(segments)]

    d = segments[next_date_segment_index(segments, 0)].split(':')
    @created_date = Date.parse(d[1])

    bf_nad_index = next_nad_segment_index(segments, 0) # may not be present in the header
    unless bf_nad_index.nil?
      nad = segments[bf_nad_index]
      @bf_id = nad.split('+')[2].to_i
    end
  end

end