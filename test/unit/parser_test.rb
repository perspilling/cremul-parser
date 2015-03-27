require_relative '../test_helper'
require 'tempfile'

describe CremulParser do

  describe 'parsing cremul files' do
    before do
      @parser = CremulParser.new
    end

    it 'should parse a valid cremul file with 1 line item' do
      @parser.parse(File.open('files/CREMUL0001-utf-8.txt'))
      @parser.segments.must_be_instance_of Array
      @parser.messages.size.must_equal 1
      @parser.messages[0].must_be_instance_of CremulMessage

      d2014_03_12 = Date.new(2014,3,12)

      msg = @parser.messages[0]
      msg.message_index.must_equal 1
      msg.header.must_be_instance_of CremulHeader
      msg.header.msg_id.must_include 'CREMUL'
      msg.header.created_date.must_equal d2014_03_12
      msg.header.bf_id.must_equal 975945065

      msg.number_of_lines.must_equal 1

      line = msg.lines[0]
      line.must_be_instance_of CremulLine
      line.line_index.must_equal 1
      line.posting_date.must_equal d2014_03_12
      line.bf_account_number.must_equal '12121212121'
      line.money.must_be_instance_of CremulMoney
      line.money.amount.must_equal 1394.to_f
      line.money.currency.must_equal :NOK

      ref = line.reference
      ref.must_be_instance_of CremulReference
      ref.type.must_equal :ACK
      ref.number.must_equal '08012992096'

      line.transactions.size.must_equal 1
      tx = line.transactions[0]
      tx.must_be_instance_of CremulPaymentTx
      tx.tx_index.must_equal 1
      tx.posting_date.must_equal d2014_03_12
      tx.money.amount.must_equal 1394.to_f
      tx.money.currency.must_equal :NOK
      tx.payer_account_number.must_equal '12312312312'
      tx.references.size.must_equal 2
      tx.free_text.must_equal 'Tømrer Morten Rognebær AS'

      ref = tx.references[0]
      ref.must_be_instance_of CremulReference
      ref.type.must_equal :AEK
      ref.number.must_equal '12072200001'

      ref = tx.references[1]
      ref.type.must_equal :ACD
      ref.number.must_equal '180229451'

      tx_payer = tx.payer_nad
      tx_payer.must_be_instance_of CremulNameAndAddress
      tx_payer.type.must_equal :PL
      tx_payer.nad_lines[1].must_equal 'Skjerpåkeren 17'


    end

    it 'should parse a valid cremul file with multiple line items' do
      @parser.parse(File.open('files/cremul_multi_lines.txt'))
      @parser.segments.must_be_instance_of Array
      @parser.messages[0].must_be_instance_of CremulMessage

      d2011_01_11 = Date.new(2011,1,11)

      msg = @parser.messages[0]
      msg.header.must_be_instance_of CremulHeader
      msg.header.msg_id.must_include 'CREMUL'
      msg.header.created_date.must_equal d2011_01_11

      msg.number_of_lines.must_equal 3

      line1 = msg.lines[0]
      line1.must_be_instance_of CremulLine
      line1.posting_date.must_equal d2011_01_11
      line1.money.must_be_instance_of CremulMoney
      line1.money.amount.must_equal 14637.to_f
      line1.money.currency.must_equal :NOK

      line1.transactions.size.must_equal 1
      tx = line1.transactions[0]
      tx.must_be_instance_of CremulPaymentTx
      tx.posting_date.must_equal d2011_01_11
      tx.money.amount.must_equal 14637.to_f
      tx.money.currency.must_equal :NOK
      tx.references.size.must_equal 2

      tx.payer_nad.must_be_instance_of CremulNameAndAddress
      tx.payer_nad.type.must_equal :PL
      tx.payer_nad.nad_lines[1].must_equal 'ØKONOMIKONTORET 5 ETG'


      line2 = msg.lines[1]
      line2.must_be_instance_of CremulLine
      line2.posting_date.must_equal d2011_01_11
      line2.money.must_be_instance_of CremulMoney
      line2.money.amount.must_equal 15000.to_f
      line2.money.currency.must_equal :NOK
      line2.transactions.size.must_equal 1

      line3 = msg.lines[2]
      line3.must_be_instance_of CremulLine
      line3.posting_date.must_equal d2011_01_11
      line3.money.must_be_instance_of CremulMoney
      line3.money.amount.must_equal '6740.40'.to_f
      line3.money.currency.must_equal :NOK
      line3.transactions.size.must_equal 2

    end

    it 'should parse a valid long cremul file' do
      @parser.parse(File.open('files/CREMUL0003-utf-8.txt'))
      @parser.segments.must_be_instance_of Array
      @parser.messages[0].must_be_instance_of CremulMessage

      d2013_04_11 = Date.new(2013,4,11)

      msg = @parser.messages[0]
      msg.header.must_be_instance_of CremulHeader
      msg.header.msg_id.must_include 'CREMUL'
      msg.header.created_date.must_equal d2013_04_11

      msg.number_of_lines.must_equal 4


      line1 = msg.lines[0]
      line1.must_be_instance_of CremulLine
      line1.posting_date.must_equal d2013_04_11
      line1.money.must_be_instance_of CremulMoney
      line1.money.amount.must_equal 3000.to_f
      line1.money.currency.must_equal :NOK

      line1.transactions.size.must_equal 12

      tx = line1.transactions[0]
      tx.must_be_instance_of CremulPaymentTx
      tx.posting_date.must_equal Date.new(2013,4,10)
      tx.money.amount.must_equal 250.to_f
      tx.money.currency.must_equal :NOK
      tx.payer_account_number.must_equal '12345678901'
      tx.invoice_ref.must_equal '20132065978'
      tx.invoice_ref_type.must_equal :KID

    end

    it 'should convert a non-utf-8 file to utf-8 on the fly' do
      @parser.parse(File.open('files/CREMUL0001.dat'), 'ISO-8859-1')
      @parser.segments.must_be_instance_of Array
      @parser.messages[0].must_be_instance_of CremulMessage

      msg = @parser.messages[0]
      line = msg.lines[0]
      tx = line.transactions[0]
      tx.must_be_instance_of CremulPaymentTx
      tx.free_text.must_equal 'Tømrer Morten Rognebær AS'

    end

    it 'should parse name and address correctly' do
      @parser.parse(File.open('files/CREMUL0002-27.05.14.DAT'), 'ISO-8859-1')
      @parser.segments.must_be_instance_of Array
      @parser.messages[0].must_be_instance_of CremulMessage

      msg = @parser.messages[0]

      tx = msg.lines[0].transactions[0]
      tx.must_be_instance_of CremulPaymentTx
      tx_payer = tx.payer_nad
      tx_payer.must_be_instance_of CremulNameAndAddress
      tx_payer.type.must_equal :PL
      tx_payer.nad_lines[0].must_equal 'Ole Thomessen'
      tx_payer.nad_lines[1].must_equal 'St. Nikolas-Gate 7'
      tx_payer.nad_lines[3].must_equal '1706 SARPSBORG'
    end

    it 'should be able to parse a file with empty FII elements' do
      @parser.parse(File.open('files/CREMUL0001-27.05.14.DAT'), 'ISO-8859-1')
      @parser.segments.must_be_instance_of Array
      @parser.messages[0].must_be_instance_of CremulMessage

      msg = @parser.messages[0]
      msg.header.must_be_instance_of CremulHeader
      msg.header.msg_id.must_include 'CREMUL'
      msg.lines[0].transactions[0].payer_account_number.must_be_nil
    end


    # ----------------------------------------------------------------------
    # the following tests are commented out as the corresponding cremul test file is not included in the Git repo
    # ----------------------------------------------------------------------


=begin
    it 'should parse a long file with multiple payment transactions' do
      @parser.parse(File.open('files/CREMUL0002_23-05-14.dat'), 'ISO-8859-1')
      @parser.segments.must_be_instance_of Array
      @parser.messages[0].must_be_instance_of CremulMessage

      msg = @parser.messages[0]

      froland_tx = msg.lines[1].transactions[1]
      froland_tx.must_be_instance_of CremulPaymentTx
      froland_tx.free_text.must_include 'kr 3.384.686,- Fradrag kr.106:.408,- Beregn.g.lag kr.3.278.2          78,-'

      braekstad_tx = msg.lines[2].transactions[0]
      braekstad_tx.invoice_ref.must_equal '20140453869'
    end
=end


    it 'should parse a multi-message file' do
      @parser.parse(File.open('files/CREMUL_multi_message.dat'), 'ISO-8859-1')
      @parser.segments.must_be_instance_of Array
      @parser.messages.size.must_equal 3
      @parser.messages[0].must_be_instance_of CremulMessage

      #write_segments_to_file(@parser.segments, File.open('files/CREMUL_multi_message_segments.txt', 'w'))
    end

    def write_segments_to_file(msg, file)
      begin
        msg.each { |segment| file.puts segment }
      ensure
        file.close
      end
    end


    # ----------------------------------------------------------------------
    # Some tests to handle file format errors (?) that we have encountered
    # ----------------------------------------------------------------------

    it 'should parse a file with a CNT:LIN symbol instead of CNT:LI as the standard says' do
      @parser.parse(File.open('files/CREMUL0001_1.dat'), 'ISO-8859-1')
      @parser.segments.must_be_instance_of Array
      @parser.messages[0].must_be_instance_of CremulMessage

      msg = @parser.messages[0]
      line = msg.lines[0]
      tx = line.transactions[0]
      tx.must_be_instance_of CremulPaymentTx
      ref = tx.references[0]
      ref.must_be_instance_of CremulReference
      ref.type.must_equal :ACK
      ref.number.must_equal 'E96151'
    end

  end

end