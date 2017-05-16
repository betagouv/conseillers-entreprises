# frozen_string_literal: true

require 'rails_helper'

describe ApiEntrepriseService do
  describe 'fetch_company_with_siren and siret' do
    let(:url) { 'https://api.apientreprise.fr/v2/entreprises/123456789?token=awesome_secured_token' }
    let(:api_entreprise_json) { '{ok: true}' }
    let(:siren) { '123456789' }

    before do
      ENV['API_ENTREPRISE_TOKEN'] = 'awesome_secured_token'
      allow(described_class).to receive(:open).with(url) { File }
      allow(File).to receive(:read) { api_entreprise_json }
      allow(JSON).to receive(:parse).with(api_entreprise_json)
    end

    after do
      expect(described_class).to have_received(:open)
      expect(File).to have_received(:read)
      expect(JSON).to have_received(:parse)
    end

    describe 'fetch_company_with_siret' do
      let(:siret) { '12345678901234' }

      it { described_class.fetch_company_with_siret siret }
    end

    describe 'fetch_company_with_siren' do
      it { described_class.send(:fetch_company_with_siren, siren) }
    end
  end
end
