# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Company do
  subject(:company) { described_class.from_siret(siret) }

  before { ENV['API_ENTREPRISE_TOKEN'] = '1234' }

  context 'SIRET number exists' do
    let(:siret) { '12345678901234' }

    before do
      stub_request(
        :get,
        'https://api.apientreprise.fr/v2/entreprises/123456789?token=1234'
      ).with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      ).to_return(
        status: 200,
        body: File.read(Rails.root.join('spec/fixtures/api_entreprise_get_entreprise.json')),
        headers: {}
      )
    end

    it 'creates an entreprise with good fields' do
      expect(company.entreprise.siren).to be_present
      expect(company.entreprise.raison_sociale).to be_present
    end

    it 'has an etablissement_siege with the right fields' do
      expect(company.etablissement_siege.siret).to be_present
    end
  end

  context 'SIRET is missing' do
    let(:siret) { '' }

    it 'raises an error' do
      expect { company }.to raise_error ApiEntreprise::Request::SirenMissingError
    end
  end
end
