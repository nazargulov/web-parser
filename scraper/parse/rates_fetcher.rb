# frozen_string_literal: true

require 'nokogiri'

module Scraper
  module Parse
    # Parsing website rates (table search)
    class RatesFetcher
      SEPARATOR = ';'

      attr_reader :document

      def self.call(document:)
        new(document: document).call
      end

      def initialize(document:)
        @document = document
      end

      def call
        parsed_document = Nokogiri::HTML(document)
        parsed_document.css('table tr').each do |tr|
          data = tr.css('td').map(&:content).join(SEPARATOR).strip
          next if data.empty?

          puts data
        end
      end
    end
  end
end
