# frozen_string_literal: true

require 'nokogiri'

module Scraper
  module Parse
    # Parsing website titles
    class TitleFetcher
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
        puts parsed_document.css('title').first.text
      end
    end
  end
end
