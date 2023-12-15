# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

RSpec.describe ApiConsumption::Company do
  let(:siren) { '418166096' }

  describe 'new' do
    let!(:api_company) { described_class.new(siren) }

    before do
      allow(described_class).to receive(:new).with(siren, {}) { api_company }
      allow(api_company).to receive(:call)
    end

    it 'calls external service' do
      described_class.new(siren,{}).call

      expect(described_class).to have_received(:new).with(siren, {})
      expect(api_company).to have_received(:call)
    end
  end

  describe 'call' do
    let(:api_company) { described_class.new(siren).call }
    let(:api_ets_base_url) { 'https://entreprise.api.gouv.fr/v3/insee/sirene/unites_legales' }

    before { Rails.cache.clear }

    context 'SIRET exists' do
      let(:searched_year) { 1.year.ago.year }
      let(:suffix_url) { "context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }

      let(:api_ets_url) { "#{api_ets_base_url}/#{siren}?#{suffix_url}" }
      let(:effectifs_url) { "https://entreprise.api.gouv.fr/v3/gip_mds/unites_legales/#{siren}/effectifs_annuels/#{searched_year}?#{suffix_url}" }
      let(:rcs_url) { "https://entreprise.api.gouv.fr/v3/infogreffe/rcs/unites_legales/#{siren}/extrait_kbis?#{suffix_url}" }
      let(:rm_url) { "https://entreprise.api.gouv.fr/v3/cma_france/rnm/unites_legales/#{siren}?#{suffix_url}" }
      let(:mandataires_url) { "https://entreprise.api.gouv.fr/v3/infogreffe/rcs/unites_legales/#{siren}/mandataires_sociaux?#{suffix_url}" }
      let(:rne_companies_url) { "https://registre-national-entreprises.inpi.fr/api/companies/#{siren}" }

      before do
        authorize_rne_token
        ENV['API_ENTREPRISE_TOKEN'] = '1234'
        stub_request(:get, api_ets_url).to_return(
          body: file_fixture('api_entreprise_entreprise.json')
        )
        stub_request(:get, effectifs_url).to_return(
          body: file_fixture('api_entreprise_effectifs_entreprise.json')
        )
        stub_request(:get, rcs_url).to_return(body: file_fixture('api_entreprise_rcs.json'))
        stub_request(:get, rm_url).to_return(body: file_fixture('api_entreprise_rm.json'))
        stub_request(:get, mandataires_url).to_return(body: file_fixture('api_entreprise_mandataires_sociaux.json'))
        stub_request(:get, rne_companies_url).to_return(body: file_fixture('api_rne_companies.json'))
      end

      it 'has the right fields' do
        expect(api_company.siren).to eq('418166096')
        expect(api_company.name).to eq("OCTO-TECHNOLOGY")
        expect(api_company.inscrit_rcs).to be(true)
        expect(api_company.inscrit_rm).to be(true)
        expect(api_company.activite_liberale).to be(false)
        expect(api_company.naf_code_a10).to eq('JZ')
        expect(api_company.naf_libelle).to eq("Conseil en systèmes et logiciels informatiques")
      end
    end
  end
end
