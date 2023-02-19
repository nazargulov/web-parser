# frozen_string_literal: true

require 'yaml'
require_relative 'scraper/queue_handler'

config = YAML.load_file('application.yml', fallback: false)
timeout = !ARGV.empty? ? ARGV[0].to_i : config['TIMEOUT'].to_i || 10
max_retry = ARGV.length > 1 ? ARGV[1].to_i : config['MAX_RETRY'].to_i || 3
pool_size = ARGV.length > 2 ? ARGV[2].to_i : config['POOL_SIZE'].to_i || 5

urls = config['URLS'].empty? ? [] : config['URLS']
::Scraper::QueueHandler.call(urls: urls, pool_size: pool_size, timeout: timeout, max_retry: max_retry)
