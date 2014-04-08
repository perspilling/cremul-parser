require_relative '../test_helper'

describe CremulParser do

  describe 'parsing valid cremul files' do
    before do
      @parser = CremulParser.new
    end

    it 'should parse a valid cremul file with 1 line item' do
      @parser.parse(File.open('files/CREMUL0001-utf-8.txt'))
      @parser.segments.must_be_instance_of Array
      @parser.msg.must_be_instance_of CremulMessage

      d2014_03_12 = Date.new(2014,3,12)

      msg = @parser.msg
      msg.header.must_be_instance_of CremulHeader
      msg.header.msg_id.must_include 'CREMUL'
      msg.header.created_date.must_equal d2014_03_12
      msg.header.bf_id.must_equal 975945065

      msg.number_of_lines.must_equal 1

      line = msg.lines[0]
      line.must_be_instance_of CremulLine
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
      tx.posting_date.must_equal d2014_03_12
      tx.money.amount.must_equal 1394.to_f
      tx.money.currency.must_equal :NOK
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
      @parser.msg.must_be_instance_of CremulMessage

      d2011_01_11 = Date.new(2011,1,11)

      msg = @parser.msg
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
      line3.money.amount.must_equal '6740,40'.to_f
      line3.money.currency.must_equal :NOK
      line3.transactions.size.must_equal 2

    end

    it 'should parse a valid long cremul file' do
      @parser.parse(File.open('files/CREMUL0003-utf-8.txt'))
      @parser.segments.must_be_instance_of Array
      @parser.msg.must_be_instance_of CremulMessage

      d2013_04_11 = Date.new(2013,4,11)

      msg = @parser.msg
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
      @parser.msg.must_be_instance_of CremulMessage

      msg = @parser.msg
      line = msg.lines[0]
      tx = line.transactions[0]
      tx.must_be_instance_of CremulPaymentTx
      tx.free_text.must_equal 'Tømrer Morten Rognebær AS'

    end


  end

end