require 'rails_helper'

RSpec.describe Api::Internal::CommunesController do
  describe 'GET #search' do
    let(:json_response) { response.parsed_body }

    before do
      Rails.cache.clear
    end

    shared_examples 'returns empty array response' do
      it 'returns an empty array' do
        expect(response).to have_http_status(:success)
        data = json_response.is_a?(Hash) ? json_response['data'] : json_response
        expect(data).to eq([])
      end
    end

    shared_examples 'returns valid commune structure' do
      it 'returns communes with required fields' do
        expect(json_response).to all(
          include('nom', 'code', 'departement_code', 'departement_nom')
        )
      end
    end

    context 'with a valid query' do
      it 'returns communes matching the query' do
        get :search, params: { q: 'Paris' }

        expect(response).to have_http_status(:success)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to be <= 20
      end

      it 'includes communes with query in name' do
        get :search, params: { q: 'Paris' }

        expect(json_response).to include(
          hash_including('nom' => a_string_matching(/Paris/i))
        )
      end

      it 'returns communes with expected structure' do
        get :search, params: { q: 'Paris' }

        expect(json_response).not_to be_empty
        expect(json_response).to all(
          include('nom', 'code', 'departement_code', 'departement_nom')
        )
      end

      it 'normalizes accents in search' do
        get :search, params: { q: 'Étretat' }

        expect(response).to have_http_status(:success)
        expect(json_response).to be_an(Array)
        expect(json_response).to include(
          hash_including('nom' => 'Étretat')
        )
      end

      it 'is case insensitive' do
        get :search, params: { q: 'MARSEILLE' }
        json_uppercase = response.parsed_body

        get :search, params: { q: 'marseille' }
        json_lowercase = response.parsed_body

        expect(json_uppercase.count).to eq(json_lowercase.count)
      end

      it 'limits results to 20 communes' do
        get :search, params: { q: 'Saint' }

        expect(json_response.length).to eq(20)
      end

      it 'uses cache mechanism' do
        expect(Rails.cache).to receive(:fetch)
          .with('communes_autocomplete_v2', expires_in: 24.hours)
          .and_call_original

        get :search, params: { q: 'Lyon' }

        expect(json_response).to be_an(Array)
        expect(json_response).not_to be_empty
      end
    end

    context 'with an empty query' do
      before do
        get :search, params: { q: '' }
      end

      it_behaves_like 'returns empty array response'
    end

    context 'with a query that has no results' do
      before do
        get :search, params: { q: 'XYZNONEXISTENT999' }
      end

      it_behaves_like 'returns empty array response'
    end

    context 'cache performance' do
      it 'builds cache efficiently without N+1 queries' do
        expect(DecoupageAdministratif::Departement).to receive(:all).once.and_call_original
        expect(DecoupageAdministratif::Commune).to receive(:all).once.and_call_original

        get :search, params: { q: 'Paris' }

        expect(response).to have_http_status(:success)
      end

      it 'cache includes departement_nom without additional queries' do
        get :search, params: { q: 'Paris' }

        expect(json_response).not_to be_empty
        expect(json_response).to all(
          include('departement_nom' => be_present)
        )
      end
    end
  end
end
