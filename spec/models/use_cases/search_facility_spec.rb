# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'

describe UseCases::SearchFacility do
  let!(:opco) { create :institution, :opco, siren: "851296632", france_competence_code: "03" }
  let(:siret) { '41816609600051' }
  let(:siren) { siret[0..8] }
  let(:token) { '1234' }
  let(:searched_month) { Time.zone.now.months_ago(2).strftime("%m") }
  let(:searched_year) { Time.zone.now.months_ago(2).year }

  let(:suffix_url) { "context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }
  let(:entreprise_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/unites_legales/#{siren}?#{suffix_url}" }
  let(:effectif_entreprise_url) { "https://entreprise.api.gouv.fr/v3/gip_mds/unites_legales/#{siren}/effectifs_annuels/#{1.year.ago.year}?#{suffix_url}" }
  let(:rcs_url) { "https://entreprise.api.gouv.fr/v3/infogreffe/rcs/unites_legales/#{siren}/extrait_kbis?#{suffix_url}" }
  let(:rm_url) { "https://entreprise.api.gouv.fr/v3/cma_france/rnm/unites_legales/#{siren}?#{suffix_url}" }
  let(:mandataires_url) { "https://entreprise.api.gouv.fr/v3/infogreffe/rcs/unites_legales/#{siren}/mandataires_sociaux?#{suffix_url}" }
  let(:etablissement_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{siret}?#{suffix_url}" }
  let(:effectif_etablissement_url) { "https://entreprise.api.gouv.fr/v3/gip_mds/etablissements/#{siret}/effectifs_mensuels/#{searched_month}/annee/#{searched_year}?#{suffix_url}" }
  let(:opco_url) { "https://www.cfadock.fr/api/opcos?siret=#{siret}" }
  let(:rne_companies_url) { "https://registre-national-entreprises.inpi.fr/api/companies/#{siren}" }
  let(:france_competence_url) { "https://api-preprod.francecompetences.fr/siropartfc/#{siret}" }

  describe 'with_siret_and_save' do
    before do
      ENV['API_ENTREPRISE_TOKEN'] = token
      authorize_rne_token
      authorize_france_competence_token
      stub_request(:get, entreprise_url).to_return(body: file_fixture('api_entreprise_entreprise.json'))
      stub_request(:get, effectif_entreprise_url).to_return(body: file_fixture('api_entreprise_effectifs_entreprise.json'))
      stub_request(:get, rcs_url).to_return(body: file_fixture('api_entreprise_rcs.json'))
      stub_request(:get, rm_url).to_return(body: file_fixture('api_entreprise_rm.json'))
      stub_request(:get, mandataires_url).to_return(body: file_fixture('api_entreprise_mandataires_sociaux.json'))
      stub_request(:get, etablissement_url).to_return(body: file_fixture('api_entreprise_etablissement.json'))
      stub_request(:get, effectif_etablissement_url).to_return(body: file_fixture('api_entreprise_effectifs_etablissement.json'))
      stub_request(:get, opco_url).to_return(body: file_fixture('api_cfadock_opco.json'))
      stub_request(:get, rne_companies_url).to_return(body: file_fixture('api_rne_companies.json'))
      stub_france_competence_siret(france_competence_url, file_fixture('api_france_competence_siret.json'))
    end

    context 'first call' do
      before do
        described_class.with_siret_and_save siret
      end

      it 'sets company and facility' do
        company = Company.last
        facility = Facility.last
        expect(company.siren).to eq siren
        expect(company.legal_form_code).to eq '5710'
        expect(company.code_effectif).to eq '41'
        expect(company.inscrit_rcs).to be true
        expect(company.inscrit_rm).to be true
        expect(company.forme_exercice).to eq 'COMMERCIALE'

        expect(facility.reload.siret).to eq siret
        expect(facility.commune.insee_code).to eq '75102'
        expect(facility.naf_code).to eq '6202A'
        expect(facility.code_effectif).to eq '41'
        expect(facility.opco).to eq opco
        expect(facility.readable_locality).to eq '75002 PARIS 2'
      end
    end

    context 'two calls' do
      it 'does not duplicate Company or Facility' do
        described_class.with_siret_and_save siret
        described_class.with_siret_and_save siret

        expect(Company.count).to eq 1
        expect(Facility.count).to eq 1
      end
    end
  end
end
