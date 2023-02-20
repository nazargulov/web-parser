# frozen_string_literal: true

require 'digest/md5'

module Scraper
  # Caching html documents to files
  class Cache
    FILENAME_SEPARATOR = '_'
    TTL = 30 * 24 * 60 * 60 # seconds

    attr_reader :url, :file

    class << self
      def expire!
        now = Time.now.to_i
        Dir[[directory, '*'].join].each do |path|
          timestamp = timestamp_from_path(path)
          File.delete(path) if now - timestamp > TTL
        end
      end

      def directory
        @directory ||= "#{Dir.getwd}/tmp/"
      end

      def timestamp_from_path(path)
        path.sub(directory, '').split(FILENAME_SEPARATOR).first.to_i
      end
    end

    def initialize(url:)
      @url = url
    end

    def fetch
      return unless block_given?

      if exists?
        read
      else
        document = yield
        write(document) unless document.nil?
        document
      end
    end

    def write(data)
      File.write(path, data)
    end

    def read
      fresh_file_path = path(ordered_file_timestamps.last)
      File.read(fresh_file_path)
    end

    def exists?
      file_paths.any?
    end

    private

    def url_md5_digest
      @url_md5_digest ||= Digest::MD5.hexdigest(@url)
    end

    def file_paths
      @file_paths ||= Dir[path('*')]
    end

    def ordered_file_timestamps
      @ordered_file_timestamps ||= file_paths.map do |path|
        self.class.timestamp_from_path(path)
      end.sort
    end

    def path(timestamp = Time.now.to_i)
      [directory, timestamp, FILENAME_SEPARATOR, url_md5_digest].join
    end

    def directory
      self.class.directory
    end
  end
end
