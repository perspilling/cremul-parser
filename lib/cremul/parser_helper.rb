module Cremul
  module ParserHelper

    ELEMENT_SEPARATOR = '+'
    DATA_SEPARATOR = ':'
    REPETITION_SEPARATOR = '*'
    SEGMENT_DELIMITER = "'"

    MESSAGE_HEADER = 'UNH'
    MESSAGE_BEGIN = 'BGM'

    LINE_ITEM_SEGMENT = 'LIN'
    DATE_SEGMENT = 'DTM'
    BUSINESS_FUNCTION_SEGMENT = 'BUS'

    REFERENCE_SEGMENT = 'RFF'
    NAME_ADDRESS_SEGMENT = 'NAD'
    SEQUENCE_SEGMENT = 'SEQ'

    FINANCIAL_INSTITUTION_SEGMENT = 'FII'
    BENEFICIARY = 'BF'
    # Example: FII+BF+12345678901' (Beneficiary bank account number)

    MONETARY_AMOUNT_SEGMENT = 'MOA'
    CURRENCIES_SEGMENT = 'CUX'

    PROCESS_TYPE_SEGMENT = 'PRC'
    FREETEXT_SEGMENT = 'FTX'

    CODES = {
        BUSINESS_FUNCTION_SEGMENT => {
            c230: 'Total amount valid KID',
            c231: 'Total amount invalid KID',
            c232: 'Total amount AutoGiro',
            c233: 'Total amount electronic payments',
            c234: 'Total amount Giro notes',
            c240: 'Total amount structured information'

        },
        MONETARY_AMOUNT_SEGMENT => {
            c60: 'Final posted amount',
            c346: 'Total credit. Sum of final posted amounts on level C',
            c349: 'Amount that will be posted/amount not confirmed by bank',
            c362: 'Amount for information – can be changed'
        },
        REFERENCE_SEGMENT => {
            ACK: 'Bank reference - KID in Norwegian',
            AII: 'Bank’s reference number allocated by the bank to different underlaying individual transactions',
            CT: 'AutoGiro agreement ID'
        }
    }

    REF_TYPES = {
        c380: :INVOICE_NUMBER,
        c381: :CREDIT_NOTE,
        c999: :KID,
        c998: :INVOICE_NUMBER
    }

    # Assumes that the parameter is a string with the code
    def ref_type(type_number)
      type_symbol = ('c' << type_number).to_sym
      REF_TYPES[type_symbol]
    end


    def segment_codes
      CODES
    end

    def msg_id_segment_index(segments)
      segments.index { |x| /^UNH.*/.match(x) }
    end

    def find_index_by_regex(segments, start_pos, end_pos=nil, regex)
      if end_pos.nil?
        end_pos = next_tx_sequence_segment_index(segments, start_pos+1)
        if end_pos.nil? # no more segments
          end_pos = segments.size
        end
      end
      index = nil
      unless end_pos.nil?
        index = segments[start_pos, end_pos-start_pos].index { |x| regex.match(x) }
        index += start_pos unless index.nil?
      end
      index
    end

    def next_date_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^DTM.*/)
    end

    def next_amount_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^MOA.*/)
    end

    def next_line_segment_index(segments, start_pos)
      find_index_by_regex(segments, start_pos, segments.size, /^LIN\+\d/)
    end

    def next_tx_sequence_segment_index(segments, start_pos)
      find_index_by_regex(segments, start_pos, segments.size, /^SEQ\+\+\d/)
    end

    def doc_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^DOC.*/)
    end

    def payment_details_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^FTX\+PMD.*/)
    end

    # Optional segment with free text info regarding the payment
    def payment_advice_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^FTX\+AAG.*/)
    end

    def next_ref_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^RFF.*/)
    end

    # Bank account of beneficiary
    def next_fii_bf_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^FII\+BF.*/)
    end

    # Bank account of payer
    def next_fii_or_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^FII\+OR.*/)
    end

    def next_nad_segment_index(segments, start_pos, end_pos=nil)
      find_index_by_regex(segments, start_pos, end_pos, /^NAD.*/)
    end

    def line_count_segment_index(segments)
      segments.index { |x| /^CNT\+LIN?:\d/.match(x) }
    end

    def number_of_lines_in_message(segments)
      s = segments[line_count_segment_index(segments)]
      s[s.index(':')+1, s.size].to_i
    end

    # Return the number of individual payments transactions in the line item. Expects 'line_segment_pos'
    # to be the index of the current line item.
    def number_of_transactions_in_line(segments, line_segment_pos)
      n = 1 # there must be at least 1 payment tx
      tx_pos = next_tx_sequence_segment_index(segments, line_segment_pos+1)
      # search for payment tx items until next line item or end of message
      next_line_index = next_line_segment_index(segments, line_segment_pos+1)
      loop do
        tx_pos = next_tx_sequence_segment_index(segments, tx_pos+1)
        if tx_pos.nil?
          break
        elsif !next_line_index.nil? && tx_pos > next_line_index
          break
        else
          n += 1
        end
      end
      n
    end

    def number_of_references_in_tx(segments, tx_segment_pos)
      n = 0
      ref_index = next_ref_segment_index(segments, tx_segment_pos)
      next_tx_index = next_tx_sequence_segment_index(segments, tx_segment_pos+1)
      next_line_index = next_line_segment_index(segments, tx_segment_pos)
      loop do
        if ref_index.nil?
          break
        elsif !next_tx_index.nil? && ref_index > next_tx_index
          break
        elsif !next_line_index.nil? && ref_index > next_line_index
          break
        else
          n += 1
        end
        ref_index = next_ref_segment_index(segments, ref_index+1)
      end
      n
    end

    def get_messages_in_file(segments)
      m = {}
      n = 0
      segments.each_index do |i|
        if /^UNA.*/.match(segments[i])
          n += 1
          m[n] = i
        end
      end
      m
    end


    def last_segment_index_in_tx(segments, tx_segment_pos)
      next_tx_index = next_tx_sequence_segment_index(segments, tx_segment_pos+1)
      next_line_index = next_line_segment_index(segments, tx_segment_pos)
      cnt_index = line_count_segment_index(segments)

      if next_tx_index
        next_tx_index - 1
      elsif next_line_index
        next_line_index - 1
      else
        cnt_index - 1
      end
    end

  end

end
