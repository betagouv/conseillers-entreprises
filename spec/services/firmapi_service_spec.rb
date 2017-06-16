# frozen_string_literal: true

require 'rails_helper'

describe FirmapiService do
  describe 'search_companies' do
    subject(:search_companies) { described_class.search_companies name: name, county: county }

    let(:name) { 'Octo' }
    let(:county) { '75' }
    let(:url) { 'https://firmapi.com/api/v1/companies?name=Octo&department=75' }

    context 'success' do
      let(:firmapi_json_raw) { "{ 'status' => 'success' }" }
      let(:firmapi_json) { { 'status' => 'success' } }

      before do
        allow(described_class).to receive(:open).with(url) { File }
        allow(File).to receive(:read) { firmapi_json_raw }
        allow(JSON).to receive(:parse).with(firmapi_json_raw) { firmapi_json }
        search_companies
      end

      it 'returns the parsed json' do
        expect(described_class).to have_received(:open)
        expect(File).to have_received(:read)
        expect(JSON).to have_received(:parse)
        is_expected.to eq firmapi_json
      end
    end

    context 'error' do
      it 'returns nil' do
        allow(described_class).to receive(:open).with(url).and_raise(OpenURI::HTTPError.new('error', 'io'))
        search_companies
        expect(described_class).to have_received(:open)
        is_expected.to be_nil
      end
    end
  end
end
