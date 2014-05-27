require_relative 'parser_helper'

class CremulNameAndAddress
  include Cremul::ParserHelper

  # NAD segment in unstructured form:
  # NAD+party-id+code+code+nad-line1+nad-line2+nad-line3+nad-line4+nad-line5
  #
  # NAD segment in structured form (3 variants):
  # NAD+party-id+code+code+nad-line OR
  # NAD+party-id+code+nad-line OR
  # NAD+party-id+nad-line
  #
  # In the structured form the nad-line will have colon (:) as separator between the address parts
  #
  # Party-IDs:
  # MR - Beneficiary bank
  # BE - Beneficiary, the ultimate recipient of the funds
  # PL - Payor

  attr_reader :type, :nad_lines

  def initialize(nad_segment)
    s = nad_segment.split('+')
    @type = s[1].to_sym

    @nad_lines = []
    if s.size <= 5 # structured form
      addr = s[s.size-1].split(':')
      addr.size.times do |i|
        @nad_lines << addr[i]
      end
    else
      5.times do |i|
        @nad_lines << s[i+4]
      end
    end
  end
end