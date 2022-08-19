require "rails_helper"
require 'swagger_helper'

RSpec.describe "Landings API", type: :request do
  path '/api/v1/landings' do
    let(:institution) { create(:institution) }

    get 'Liste des pages formulaires' do
      tags 'Landings'
      description 'Affiche toutes les pages formulaires pour l\'organisation authentifiée'
      produces 'application/json'

      response '200', 'ok' do
        let(:Authorization) { "Bearer token=#{find_token(institution)}" }
        let!(:landing_01) { create(:landing, :api, institution: institution, title: 'Landing 01') }
        let!(:landing_02) { create(:landing, :api, title: 'Landing 02') }
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   title: { type: :string },
                   slug: { type: :string },
                   partner_url: { type: :string }
                 }
               }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a valid 200 response' do |example|
          expect(response.status).to eq(200)
          result = JSON.parse(response.body)
          expect(result.size).to eq(2)
          expect(result['data']).to eq([
            {
              "id" => landing_01.id,
              "iframe_category" => "integral",
              "partner_url" => 'https://www.example.com/aides',
              "slug" => landing_01.slug,
              "title" => 'Landing 01'
            }
          ])
        end
      end

      response '404', 'Mauvais token' do
        let(:Authorization) { "Bearer token=tatayoyo}" }

        run_test! do |response|
          expect(response.status).to eq(404)
          result = JSON.parse(response.body)
          expect(result["errors"].first.keys).to eq(['Token d’API'])
          expect(result["errors"].first.values).to eq(['n’existe pas ou est invalide'])
        end
      end
    end
  end
end
