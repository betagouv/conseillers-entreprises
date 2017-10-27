# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Firmapi::FirmsSearch do
  subject(:firms_search) { described_class.new.fetch(name, county) }

  let(:name) { 'Octo' }
  let(:county) { '75' }
  let(:url) { 'https://firmapi.com/api/v1/companies?department=75&name=Octo' }

  let(:httprb_request_headers) do
    { 'Connection' => 'close', 'Host' => 'firmapi.com', 'User-Agent' => 'http.rb/3.0.0' }
  end

  before { Rails.cache.clear }

  context 'regular case' do
    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 200, headers: {},
        body: File.read(Rails.root.join('spec/fixtures/firmapi_get_firms.json'))
      )
    end

    it 'retrieves the relevant JSON' do
      expect(firms_search.companies.first['siren']).to eq '810579037'
    end
  end

  context 'when there is a server error' do
    before do
      stub_request(:get, url).with(headers: httprb_request_headers).to_return(
        status: 500, headers: {}, body: '{}'
      )
    end

    it 'raises an error' do
      expect { firms_search }.to raise_error Firmapi::FirmapiError
    end
  end
end
