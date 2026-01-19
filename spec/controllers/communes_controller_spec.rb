require 'rails_helper'

RSpec.describe CommunesController do
  describe 'GET #search' do
    before do
      # Clear cache before each test
      Rails.cache.clear
    end

    context 'with a valid query' do
      it 'returns communes matching the query' do
        get :search, params: { q: 'Paris' }

        expect(response).to be_successful
        json = response.parsed_body
        expect(json).to be_an(Array)
        expect(json.length).to be <= 20

        # Should include Paris and communes with "paris" in the name
        expect(json.any? { |c| c['nom'].include?('Paris') }).to be true

        # Each result should have the expected structure
        if json.any?
          first_result = json.first
          expect(first_result).to have_key('nom')
          expect(first_result).to have_key('code')
          expect(first_result).to have_key('departement_code')
          expect(first_result).to have_key('departement_nom')
        end
      end

      it 'normalizes accents in search' do
        get :search, params: { q: 'Étretat' }

        expect(response).to be_successful
        json = response.parsed_body
        expect(json).to be_an(Array)

        # Should find Étretat (76254) even with accents in query
        expect(json.any? { |c| c['nom'] == 'Étretat' }).to be true
      end

      it 'is case insensitive' do
        get :search, params: { q: 'MARSEILLE' }

        json_uppercase = response.parsed_body

        get :search, params: { q: 'marseille' }
        json_lowercase = response.parsed_body

        # Should return the same results regardless of case
        expect(json_uppercase.count).to eq(json_lowercase.count)
      end

      it 'limits results to 20 communes' do
        get :search, params: { q: 'Saint' }

        json = response.parsed_body
        expect(json.length).to eq(20)
      end

      it 'uses cache mechanism' do
        # The controller should use Rails.cache.fetch
        expect(Rails.cache).to receive(:fetch)
          .with('communes_autocomplete_v2', expires_in: 24.hours)
          .and_call_original

        get :search, params: { q: 'Lyon' }
        first_json = response.parsed_body
        expect(first_json).to be_an(Array)
        expect(first_json.any?).to be true
      end
    end

    context 'with a query shorter than 3 characters' do
      it 'returns an empty array' do
        get :search, params: { q: 'Pa' }

        expect(response).to be_successful
        json = response.parsed_body
        # Handle both raw array and wrapped response
        data = json.is_a?(Hash) ? json['data'] : json
        expect(data).to eq([])
      end
    end

    context 'with an empty query' do
      it 'returns an empty array' do
        get :search, params: { q: '' }

        expect(response).to be_successful
        json = response.parsed_body
        # Handle both raw array and wrapped response
        data = json.is_a?(Hash) ? json['data'] : json
        expect(data).to eq([])
      end
    end

    context 'with a query that has no results' do
      it 'returns an empty array' do
        get :search, params: { q: 'XYZNONEXISTENT999' }

        expect(response).to be_successful
        json = response.parsed_body
        # Handle both raw array and wrapped response
        data = json.is_a?(Hash) ? json['data'] : json
        expect(data).to eq([])
      end
    end

    context 'cache performance' do
      it 'builds cache efficiently without N+1 queries' do
        # Clear cache to force rebuild
        Rails.cache.clear

        # Mock to verify we're using index_by (no repeated finds)
        expect(DecoupageAdministratif::Departement).to receive(:all).once.and_call_original
        expect(DecoupageAdministratif::Commune).to receive(:all).once.and_call_original

        get :search, params: { q: 'Paris' }

        expect(response).to be_successful
      end

      it 'cache includes departement_nom without additional queries' do
        get :search, params: { q: 'Paris' }

        json = response.parsed_body
        expect(json.any?).to be true

        # All results should have departement_nom populated
        json.each do |commune|
          expect(commune['departement_nom']).to be_present
        end
      end
    end
  end
end
