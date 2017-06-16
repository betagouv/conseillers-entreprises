# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Company do
  before do
    ENV['API_ENTREPRISE_TOKEN'] = '1234'
  end

  context 'I have a good siret' do
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
        body: File.read(Rails.root.join('spec/responses/api_entreprise.json')),
        headers: {}
      )
    end

    context 'I have a company' do
      let(:company) { described_class.from_siret(siret) }

      it 'create an entreprise that have good fields' do
        expect(company.entreprise.siren).to be_present
        expect(company.entreprise.raison_sociale).to be_present
      end

      it 'have an etablissement_siege with right fields' do
        expect(company.etablissement_siege.siret).to be_present
      end
    end
  end

  context 'I have a bad siret' do
    it 'raise an error' do
      expect { described_class.from_siret('') }.to raise_error ApiEntreprise::Company::Request::SirenMissingError
    end
  end
end
