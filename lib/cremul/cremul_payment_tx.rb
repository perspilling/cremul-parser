require_relative 'parser_helper'
require_relative 'cremul_reference'
require_relative 'cremul_name_and_address'

# Represents an individual payment transaction (SEQ segment) i a CREMUL message
class CremulPaymentTx
  include Cremul::ParserHelper

  # Normal format:
  # FII+<party-id>+<account identification>
  #
  # Emtpy format (no bank account info given):
  # FII+<party-id>
  #
  # Party-id:
  # OR - Payor's bank account
  # I2 - Beneficiary's bank account

  REF_TYPE_KID = 999 # Norwegian customer invoice reference
  REF_TYPE_INVOICE_NUMBER = 380

  attr_reader :posting_date, :money, :references, :invoice_ref_type, :invoice_ref, :free_text
  attr_reader :payer_account_number, :payer_nad, :beneficiary_nad, :tx_index


  def initialize(tx_index, segments, tx_segment_pos)
    @tx_index = tx_index  # the index number of this tx within it's parent line
    s = segments[next_date_segment_index(segments, tx_segment_pos)].split(':')
    @posting_date = Date.parse(s[1])

    s = segments[next_fii_or_segment_index(segments, tx_segment_pos)].split('+')
    if s.size == 3 # bank account number is provided
      if s[2].include? ':'
        @payer_account_number = s[2].split(':')[0] # the part after the : is the payer account holder name
      else
        @payer_account_number = s[2]
      end
    end

    init_invoice_ref(segments, tx_segment_pos)
    init_free_text(segments, tx_segment_pos)

    @money = CremulMoney.new(segments[next_amount_segment_index(segments, tx_segment_pos)])

    init_refs(segments, tx_segment_pos)
    init_name_and_addresses(segments, tx_segment_pos)
  end

  def to_csv(decimal_separator)
    if decimal_separator == ','
      amount = @money.amount.to_s.gsub('.', ',')
    else
      amount = @money.amount.to_s
    end
    "#{@posting_date};#{amount};#{@money.currency};#{@payer_account_number};#{invoice_ref_type};#{invoice_ref};#{free_text};#{@payer_nad.to_csv}"
  end

  private

  def init_free_text(segments, tx_segment_pos)
    i = payment_details_segment_index(segments, tx_segment_pos)
    unless i.nil?
      s = segments[i].split('+')
      @free_text = s[s.size-1]
    end
  end

  def init_invoice_ref(segments, tx_segment_pos)
    i = doc_segment_index(segments, tx_segment_pos)
    unless i.nil?
      s = segments[doc_segment_index(segments, tx_segment_pos)].split('+')
      @invoice_ref_type = ref_type(s[1])
      @invoice_ref = s[2]
    end
  end

  def init_name_and_addresses(segments, tx_segment_pos)
    n = last_segment_index_in_tx(segments, tx_segment_pos)
    nad_index = next_nad_segment_index(segments, tx_segment_pos)
    while nad_index.nil? == false && nad_index <= n
      nad = CremulNameAndAddress.new(segments[nad_index])
      assign_nad(nad)
      nad_index = next_nad_segment_index(segments, nad_index+1)
    end
  end

  def init_refs(segments, tx_segment_pos)
    @references = []
    n = number_of_references_in_tx(segments, tx_segment_pos)
    ref_segment_index = next_ref_segment_index(segments, tx_segment_pos)
    n.times do
      @references << CremulReference.new(segments[ref_segment_index])
      ref_segment_index = next_ref_segment_index(segments, ref_segment_index+1)
    end
  end

  def assign_nad(nad)
    if nad.type == :PL
      @payer_nad = nad
    elsif nad.type == :BE
      @beneficiary_nad = nad
    end
  end

end