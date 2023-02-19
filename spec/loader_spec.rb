# frozen_string_literal: true

require 'spec_helper'
require_relative '../scraper/loader'

RSpec.describe Scraper::Loader do
  let!(:url) { 'http://www.example.com' }
  let!(:document) { '<html></html>' }
  let!(:cache) { Scraper::Cache.new(url: url) }
  let!(:url_md5_digest) { Digest::MD5.hexdigest(url) }
  before { stub_request(:any, url).to_return(body: document) }

  let!(:current_time) { Time.now }

  around do |ex|
    Timecop.freeze(current_time) { ex.run }
  end

  describe '#call' do
    subject(:call) { described_class.new.call(url: url) }

    let(:file_path) do
      [Scraper::Cache.directory, current_time.to_i, Scraper::Cache::FILENAME_SEPARATOR, url_md5_digest].join
    end

    after { File.delete(file_path) if File.exist?(file_path) }

    context 'valid' do
      it 'load html' do
        expect(call).to eq(document)
      end
    end

    context 'when error raised' do
      before { allow(HTTParty).to receive(:get).and_raise(StandardError) }

      it 'retries' do
        call
        expect(HTTParty).to have_received(:get).exactly(described_class::RETRY).times
      end
    end

    context 'when a timeout is exceeded' do
      subject(:call) { described_class.new.call(url: url, timeout: 1) }

      before do
        allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)
      end

      it 'retries' do
        call
        expect(HTTParty).to have_received(:get).exactly(described_class::RETRY).times
      end
    end
  end
end
