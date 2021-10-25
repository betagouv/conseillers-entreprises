# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiConsumption::Facility do
  let(:facility) { described_class.new(siret).call }
  let(:api_ets_base_url) { 'https://entreprise.api.gouv.fr/v2/etablissements' }
  let(:cfadock_base_url) { 'https://www.cfadock.fr/api/opcos?siret=' }

  before { Rails.cache.clear }

  context 'SIRET exists' do
    let(:token) { '1234' }
    let!(:siret) { '41816609600069' }
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
      expect(facility.siret).to eq('41816609600069')
      expect(facility.code_region).to eq('11')
    end
  end
end
