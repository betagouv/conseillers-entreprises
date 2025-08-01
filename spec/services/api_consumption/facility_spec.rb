# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

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
    let(:api_ets_base_url) { 'https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements' }
    let(:france_competence_url) { "https://api.francecompetences.fr/siropartfc/v1/api/partenaire/#{siret}" }
    let(:effectifs_url) { "https://entreprise.api.gouv.fr/v3/gip_mds/etablissements/#{siret}/effectifs_mensuels/#{searched_month}/annee/#{searched_year}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }
    let(:recherche_entreprise_url) { "https://recherche-entreprises.api.gouv.fr/search?mtm_campaign=conseillers-entreprises&q=#{siret}" }

    before { Rails.cache.clear }

    context 'SIRET exists' do
      let(:api_ets_url) { "#{api_ets_base_url}/#{siret}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }
      let(:rne_companies_url) { "https://registre-national-entreprises.inpi.fr/api/companies/#{siret[0..8]}" }
      let(:searched_month) { Time.zone.now.months_ago(2).strftime("%m") }
      let(:searched_year) { Time.zone.now.months_ago(2).year }

      before do
        ENV['API_ENTREPRISE_TOKEN'] = '1234'
        authorize_france_competence_token
        authorize_rne_token
        stub_request(:get, api_ets_url).to_return(body: file_fixture('api_entreprise_etablissement.json'))
        stub_france_competence_siret(france_competence_url, file_fixture('api_france_competence_siret.json'))
        stub_request(:get, effectifs_url).to_return(
          body: file_fixture('api_entreprise_effectifs_etablissement.json')
        )
        stub_request(:get, rne_companies_url).to_return(body: file_fixture('api_rne_companies.json'))
        stub_request(:get, recherche_entreprise_url).to_return(body: file_fixture('api_recherche_entreprises_search_siret.json'))
      end

      it 'has the right fields' do
        expect(api_facility.siret).to eq('41816609600069')
        expect(api_facility.code_region).to eq('11')
        expect(api_facility.code_effectif).to eq('41')
      end
    end
  end
end
