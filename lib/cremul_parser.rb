# encoding: UTF-8

require 'logger'
require 'digest'
require_relative 'cremul/parser_helper'
require_relative 'cremul/cremul_message'


#
# A file may contain one or more Cremul messages. A Cremul message consists of 'message segments'.
# Each segment starts with a Cremul keyword. A group of segments make up a logical element of the
# Cremul message. The overall logical structure of a Cremul message is as follows:
#
# [ Cremul message ] 1 --- * [ Line ] 1 --- * [ Payment TX ]
#
class CremulParser
  include Cremul::ParserHelper

  # ----------- class attributes and methods -----------

  @logger = if defined?(Rails)
              Rails.logger
            elsif defined?(RAILS_DEFAULT_LOGGER)
              RAILS_DEFAULT_LOGGER
            else
              Logger.new(STDOUT)
            end

  def self.logger
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end

  @filename = nil

  def self.filename
    @filename
  end

  def self.filename=(filename)
    @filename = filename
  end

  # ----------- instance attributes and methods -----------

  attr_reader :segments, :messages

  def initialize
    unless defined?(Rails) || defined?(RAILS_DEFAULT_LOGGER)
      formatter = Proc.new { |severity, time, progname, msg|
        formatted_severity = sprintf("%-5s", severity.to_s)
        formatted_time = time.strftime("%Y-%m-%d %H:%M:%S")
        "[#{formatted_severity} #{formatted_time} #{$$}] #{msg.to_s.strip}\n"
      }
      self.class.logger.formatter = formatter
    end
    @messages = []
  end

  # noinspection RubyResolve
  def parse(file, file_encoding='utf-8')
    self.class.filename = File.basename(file.path)

    file_as_a_string = ''
    file.each do |line|
      unless file_encoding == 'utf-8'
        line = line.encode('utf-8', file_encoding)
      end
      file_as_a_string += line.chomp # remove \n and \r from the end of the line
    end
    @cremul_file_hash = CremulParser::get_file_hash_value(file)
    @segments = file_as_a_string.split("'")
    @segments.each { |s| s.strip! }
    # remove last segment if it is an empty string
    if @segments[@segments.size-1].empty?
      @segments = @segments.slice(0, @segments.size-1)
    end

    m = get_messages_in_file(@segments)
    if m.size == 0
      raise 'No CREMUL message found in file'
    end
    m.each do |n, start_index|
      CremulParser.logger.info "CremulParser: file=#{CremulParser.filename}, parsing message #{n}"
      if n < m.size
        @messages << CremulMessage.new(n, @segments[start_index, m[n+1] - start_index])
      else
        @messages << CremulMessage.new(n, @segments[start_index, @segments.size - start_index])
      end
    end
  end

  # Returns a unique hash value for the file. Can be used to check if the file has been read before.
  def self.get_file_hash_value(file)
    cremul_file_hash = Digest::MD5.hexdigest(file.read)
    file.rewind
    cremul_file_hash
  end

  # Writes the parsed Cremul-file to a CSV-file.
  def to_csv_file(csv_filename, decimal_separator=',')
    File.open(csv_filename, 'w') do |csv_file|
      csv_file.puts 'tx_id;posting_date;amount;currency;payer_account_number;invoice_ref_type;invoice_ref;free_text;payer name and address'
      @messages.each do |cremul_msg|
        cremul_msg.lines.each do |cremul_msg_line|
          cremul_msg_line.transactions.each do |cremul_tx|
            tx_index = create_unique_tx_index(cremul_msg, cremul_msg_line, cremul_tx)
            csv_file.puts to_csv(tx_index, cremul_tx, decimal_separator)
          end
        end
      end
    end

  end

  # Creates a unique id for each TX in the file
  def create_unique_tx_index(cremul_msg, cremul_msg_line, cremul_tx)
    file_hash = @cremul_file_hash[0, 8].force_encoding('utf-8')
    "#{file_hash}:msg#{cremul_msg.message_index}:line#{cremul_msg_line.line_index}:tx#{cremul_tx.tx_index}"
  end

  private

  def tx_id(cremul_msg, cremul_msg_line, cremul_tx)
    "M#{cremul_msg.message_index}.L#{cremul_msg_line.line_index}.TX#{cremul_tx.tx_index}"
  end


  def to_csv(tx_id, cremul_tx, decimal_separator)
    "#{tx_id};" + cremul_tx.to_csv(decimal_separator)
  end

end

