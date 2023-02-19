# frozen_string_literal: true

require 'spec_helper'
require_relative '../scraper/cache'

RSpec.describe Scraper::Cache do
  let!(:url) { 'www.example.com' }
  let!(:cache) { described_class.new(url: url) }
  let!(:url_md5_digest) { Digest::MD5.hexdigest(url) }

  let!(:current_time) { Time.now }

  around do |ex|
    Timecop.freeze(current_time) { ex.run }
  end

  describe '#fetch' do
    subject(:fetch) { cache.fetch { document } }

    let(:document) { '<html></html>' }
    let(:file_path) do
      [described_class.directory, current_time.to_i, described_class::FILENAME_SEPARATOR, url_md5_digest].join
    end

    before { fetch }
    after { File.delete(file_path) }

    it 'creates file' do
      expect(File.exist?(file_path)).to be_truthy
    end
  end
end
