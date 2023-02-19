# frozen_string_literal: true

require 'celluloid'
require_relative 'loader'
require_relative 'cache'
require_relative 'parse/rates_fetcher'
require_relative 'parse/title_fetcher'

module Scraper
  # URL's queue handler
  class QueueHandler
    POOL_SIZE = 5

    attr_reader :urls, :pool_size, :rate_limit, :timeout, :max_retry

    def self.call(urls:, timeout:, max_retry:, pool_size: POOL_SIZE)
      ::Scraper::Cache.expire!
      new(urls: urls, pool_size: pool_size, timeout: timeout, max_retry: max_retry).call
    end

    def initialize(urls:, pool_size:, timeout:, max_retry:)
      @urls = urls
      @pool_size = pool_size.positive? ? pool_size : POOL_SIZE
      @timeout = timeout
      @max_retry = max_retry
    end

    def call
      loader = ::Scraper::Loader.pool(size: pool_size)
      futures = urls.map do |url|
        loader.future.call(url: url, timeout: timeout, max_retry: max_retry)
      end
      futures.map do |future|
        document = future.value
        Scraper::Parse::TitleFetcher.call(document: document)
        Scraper::Parse::RatesFetcher.call(document: document)
      end
    end
  end
end
