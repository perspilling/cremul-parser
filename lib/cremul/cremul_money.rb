require_relative 'parser_helper'

class CremulMoney
  include Cremul::ParserHelper

  DEFAULT_CURRENCY = :NOK

  attr_reader :amount, :currency

  def initialize(money_segment)
    m = money_segment.split(':')

    @amount = m[1].to_f
    if m.size == 3
      @currency = m[2].to_sym
    else
      @currency = DEFAULT_CURRENCY
    end

  end

end