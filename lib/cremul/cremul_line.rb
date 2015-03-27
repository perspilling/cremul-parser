require_relative 'parser_helper'
require_relative 'cremul_reference'
require_relative 'cremul_money'
require_relative 'cremul_payment_tx'

# Represents a line item in a CREMUL payment transaction message. A line item may have
# 1-* child-elements with the individual payments. A line item will have an amount field
# which will be the sum of the amounts of the child payment items.
class CremulLine
  include Cremul::ParserHelper

  attr_reader :line_index, :posting_date, :money, :reference, :bf_account_number, :transactions

  def initialize(line_index, segments, line_segment_pos)
    @line_index = line_index
    d = segments[next_date_segment_index(segments, line_segment_pos)].split(':')
    @posting_date = Date.parse(d[1])

    @reference = CremulReference.new(segments[next_ref_segment_index(segments, line_segment_pos)])
    @money = CremulMoney.new(segments[next_amount_segment_index(segments, line_segment_pos)])
    bf = segments[next_fii_bf_segment_index(segments, line_segment_pos)].split('+')
    @bf_account_number = bf[2]

    @transactions = []
    n = number_of_transactions_in_line(segments, line_segment_pos)
    tx_index = next_tx_sequence_segment_index(segments, line_segment_pos)

    n.times do |i|
      CremulParser.logger.info "CremulParser: file=#{CremulParser.filename}, parsing tx #{i+1}"
      @transactions << CremulPaymentTx.new(i+1, segments, tx_index)
      tx_index = next_tx_sequence_segment_index(segments, tx_index+1)
    end

  end

end