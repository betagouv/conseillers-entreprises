# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiConsumption::Facility do
  let(:siret) { '41816609600069' }

  describe 'new' do
    let!(:api_facility) { described_class.new(siret) }

    before do
      allow(described_class).to receive(:new).with(siret, {}) { api_facility }
      allow(api_facility).to receive(:call)
    end

    it 'calls external service' do
      described_class.new(siret,{}).call

      expect(described_class).to have_received(:new).with(siret, {})
      expect(api_facility).to have_received(:call)
    end
  end

  describe 'call' do
    let(:api_facility) { described_class.new(siret).call }
    let(:api_ets_base_url) { 'https://entreprise.api.gouv.fr/v2/etablissements' }
    let(:cfadock_base_url) { 'https://www.cfadock.fr/api/opcos?siret=' }

    before { Rails.cache.clear }

    context 'SIRET exists' do
      let(:token) { '1234' }
      let(:api_ets_url) { "#{api_ets_base_url}/#{siret}?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }
      let(:cfadock_url) { "#{cfadock_base_url}#{siret}" }

      before do
        ENV['API_ENTREPRISE_TOKEN'] = token
        stub_request(:get, api_ets_url).to_return(
          body: file_fixture('api_entreprise_get_etablissement.json')
        )
        stub_request(:get, cfadock_url).to_return(
          body: file_fixture('api_cfadock_get_opco.json')
        )
      end

      it 'has the right fields' do
        expect(api_facility.siret).to eq('41816609600069')
        expect(api_facility.code_region).to eq('11')
      end
    end
  end
end
