require_relative 'parser_helper'

class CremulHeader
  include Cremul::ParserHelper

  # bf_id : Beneficiary ID. When the beneficiary is an organization this will be the organzation-number,
  #         and when the beneficiary is a person this will be the SSN, aka personnummer (NO).

  #attr_reader :header_segments, :msg_id, :created_date, :bf_id
  attr_reader :msg_id, :created_date, :bf_id

  # Expects an array with all segments in the CREMUL file
  def initialize(segments)
    #i = next_line_segment_index(segments, 0)
    #@header_segments = {}
    #segments[0,i].each {|s| @header_segments[s[0,3]] = s[3,s.size] }

    @msg_id = segments[msg_id_segment_index(segments)]

    d = segments[next_date_segment_index(segments, 0)].split(':')
    @created_date = Date.parse(d[1])

    nad = segments[next_nad_segment_index(segments, 0)]
    @bf_id = nad.split('+')[2].to_i
  end

end