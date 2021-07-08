# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiEntreprise::Entreprises do
  let(:company) { described_class.new(token, { url_keys: [:entreprises] }).fetch(siren) }

  let(:entreprises_base_url) { 'https://entreprise.api.gouv.fr/v2/entreprises' }

  before { Rails.cache.clear }

  context 'only entreprises call' do
    context 'SIREN number exists' do
      let(:token) { '1234' }
      let(:siren) { '123456789' }
      let(:url) { "#{entreprises_base_url}/123456789?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

      before do
        stub_request(:get, url).to_return(
          body: file_fixture('api_entreprise_get_entreprise.json')
        )
      end

      it 'creates an entreprise with good fields' do
        expect(company.entreprise.siren).to be_present
        expect(company.entreprise.raison_sociale).to be_present
      end

      it 'has an etablissement_siege with the right fields' do
        expect(company.etablissement_siege.siret).to be_present
      end

      it 'doesnt set rcs subscription' do
        expect(company.entreprise.inscrit_rcs).to eq nil
      end

      it 'doesnt set rm subscription' do
        expect(company.entreprise.inscrit_rm).to eq nil
      end
    end

    context 'SIREN is missing' do
      let(:token) { '1234' }
      let(:siren) { '' }
      let(:url) { "#{entreprises_base_url}/?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

      before do
        stub_request(:get, url).to_return(
          status: 500, body: '{}'
        )
      end

      it 'raises an error' do
        expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
      end
    end

    context 'SIREN does not exist' do
      let(:token) { '1234' }
      let(:siren) { '' }
      let(:url) { "#{entreprises_base_url}/?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

      before do
        stub_request(:get, url).to_return(
          status: 500,
          body: file_fixture('api_entreprise_get_entreprise_422.json')
        )
      end

      it 'raises an error' do
        expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
      end
    end

    context 'Token is unauthorized' do
      let(:token) { '' }
      let(:siren) { '123456789' }
      let(:url) { "#{entreprises_base_url}/123456789?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=" }

      before do
        stub_request(:get, url).to_return(
          status: 401,
          body: file_fixture('api_entreprise_401.json')
        )
      end

      it 'raises an error' do
        expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
      end
    end
  end

  context 'All calls' do
    let(:company) { described_class.new(token, {}).fetch(siren) }
    let(:rcs_base_url) { 'https://entreprise.api.gouv.fr/v2/extraits_rcs_infogreffe' }
    let(:rm_base_url) { 'https://entreprise.api.gouv.fr/v2/entreprises_artisanales_cma' }

    context 'SIREN number exists and company is inscrit_rcs' do
      let(:token) { '1234' }
      let(:siren) { '123456789' }
      let(:url_base_params) { '/123456789?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234' }

      before do
        stub_request(:get, "#{entreprises_base_url}#{url_base_params}&non_diffusables=true").to_return(
          body: file_fixture('api_entreprise_get_entreprise.json')
        )
        stub_request(:get, "#{rcs_base_url}#{url_base_params}").to_return(
          body: file_fixture('api_entreprise_extraits_rcs_infogreffe.json')
        )
        stub_request(:get, "#{rm_base_url}#{url_base_params}").to_return(
          body: file_fixture('api_entreprise_entreprises_artisanales_cma.json')
        )
      end

      it 'creates an entreprise with good fields' do
        expect(company.entreprise.siren).to be_present
        expect(company.entreprise.raison_sociale).to be_present
      end

      it 'returns rcs subscription' do
        expect(company.entreprise.inscrit_rcs).to eq true
      end

      it 'returns rm subscription' do
        expect(company.entreprise.inscrit_rm).to eq true
      end
    end

    context 'SIREN number exists and company NOT inscrit_rcs NOR RM' do
      let(:token) { '1234' }
      let(:siren) { '123456789' }
      let(:url_base_params) { '/123456789?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234' }

      before do
        stub_request(:get, "#{entreprises_base_url}#{url_base_params}&non_diffusables=true").to_return(
          body: file_fixture('api_entreprise_get_entreprise.json')
        )
        stub_request(:get, "#{rcs_base_url}#{url_base_params}").to_return(
          body: file_fixture('api_entreprise_extraits_rcs_infogreffe_404.json')
        )
        stub_request(:get, "#{rm_base_url}#{url_base_params}").to_return(
          body: file_fixture('api_entreprise_entreprises_artisanales_cma_404.json')
        )
      end

      it 'creates an entreprise with good fields' do
        expect(company.entreprise.siren).to be_present
      end

      it 'returns no rcs subscription' do
        expect(company.entreprise.inscrit_rcs).to eq false
      end

      it 'returns no rm subscription' do
        expect(company.entreprise.inscrit_rm).to eq false
      end
    end

    context 'SIREN is missing' do
      let(:token) { '1234' }
      let(:siren) { '' }
      let(:url_base_params) { "/?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

      before do
        stub_request(:get, "#{entreprises_base_url}#{url_base_params}&non_diffusables=true").to_return(
          status: 500, body: '{}'
        )
        stub_request(:get, "#{rcs_base_url}#{url_base_params}").to_return(
          status: 500, body: '{}'
        )
        stub_request(:get, "#{rm_base_url}#{url_base_params}").to_return(
          status: 500, body: '{}'
        )
      end

      it 'raises an error' do
        expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
      end
    end

    context 'SIREN does not exist' do
      let(:token) { '1234' }
      let(:siren) { '' }
      let(:url_base_params) { "/?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }

      before do
        stub_request(:get, "#{entreprises_base_url}#{url_base_params}&non_diffusables=true").to_return(
          status: 500,
          body: file_fixture('api_entreprise_get_entreprise_422.json')
        )
        stub_request(:get, "#{rcs_base_url}#{url_base_params}").to_return(
          status: 500,
          body: file_fixture('api_entreprise_extraits_rcs_infogreffe_422.json')
        )
        stub_request(:get, "#{rm_base_url}#{url_base_params}").to_return(
          status: 500,
          body: file_fixture('api_entreprise_entreprises_artisanales_cma_422.json')
        )
      end

      it 'raises an error' do
        expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
      end
    end

    context 'Token is unauthorized' do
      let(:token) { '' }
      let(:siren) { '123456789' }
      let(:url_base_params) { "/#{siren}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=#{token}" }

      before do
        stub_request(:get, "#{entreprises_base_url}#{url_base_params}&non_diffusables=true").to_return(
          status: 401,
          body: file_fixture('api_entreprise_401.json')
        )
        stub_request(:get, "#{rcs_base_url}#{url_base_params}").to_return(
          status: 401,
          body: file_fixture('api_entreprise_401.json')
        )
        stub_request(:get, "#{rm_base_url}#{url_base_params}").to_return(
          status: 401,
          body: file_fixture('api_entreprise_401.json')
        )
      end

      it 'raises an error' do
        expect { company }.to raise_error ApiEntreprise::ApiEntrepriseError
      end
    end
  end
end
