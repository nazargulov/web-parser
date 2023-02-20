# frozen_string_literal: true

require 'HTTParty'
require 'celluloid/autostart'
require 'celluloid/pool'
require 'ruby-limiter'

require_relative 'cache'

module Scraper
  # Loading html documents with error handling
  class Loader
    include Celluloid
    extend Limiter::Mixin

    TIMEOUT = 10 # seconds
    RATE_LIMIT = 300 # times per minute
    RETRY = 3
    POOL_SIZE = 5

    attr_reader :url, :cache, :timeout, :times_retried

    limit_method :load, rate: RATE_LIMIT

    def call(url:, timeout: TIMEOUT, max_retry: RETRY)
      @url = url
      @times_retried = 0
      @max_retry = max_retry
      @timeout = timeout

      ::Scraper::Cache.new(url: url).fetch { load(url, timeout: timeout) }
    end

    private

    def load(url, timeout:)
      responce = HTTParty.get(url, timeout: timeout)
      responce&.body
    rescue StandardError => e
      puts "Error for url (#{url}) (attempt: #{@times_retried}): #{e}"
      @times_retried += 1
      retry if @times_retried < @max_retry
    end
  end
end
