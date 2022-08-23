require "rails_helper"
require 'swagger_helper'

RSpec.describe "Landings API", type: :request do
  let(:institution) { create(:institution) }
  let!(:landing_01) { create(:landing, :with_subjects, :api, institution: institution, title: 'DINUM recrutement', slug: 'dinum-recrutement') }

  # Génération automatique des exemples dans la doc
  after do |example|
    content = example.metadata[:response][:content] || {}
    example_spec = {
      "application/json" => {
        examples: {
          test_example: {
            value: JSON.parse(response.body, symbolize_names: true)
          }
        }
      }
    }
    example.metadata[:response][:content] = content.deep_merge(example_spec)
  end

  describe 'index' do
    path '/api/v1/landings' do
      get 'Liste des pages formulaires' do
        tags 'Landings'
        description 'Affiche toutes les pages formulaires pour l\'organisation authentifiée'
        produces 'application/json'

        response '200', 'ok' do
          schema type: :object,
                 properties: {
                   data: {
                     type: :array,
                     items: {
                       '$ref': "#/components/schemas/landing"
                     }
                   },
                   metadata: {
                     type: :object,
                     properties: {
                       total_results: {
                         type: :integer,
                         description: 'Nombre de pages formulaires pour l’organisation authentifiée.'
                       }
                     }
                   }
                 }
          let(:Authorization) { "Bearer token=#{find_token(institution)}" }
          let!(:landing_02) { create(:landing, :api, title: 'Landing 02') }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = JSON.parse(response.body)
            expect(result.size).to eq(2)
            expect(result['data'].size).to eq(1)

            result_landing = result['data'].first
            expect(result_landing.keys).to match_array(["id", "title", "slug", "partner_url", "iframe_category", "landing_themes"])
            expect(result_landing["title"]).to eq('DINUM recrutement')
          end
        end

        response '404', 'Mauvais token' do
          schema errors: {
            type: :array,
                 items: {
                   '$ref': "#/components/schemas/error"
                 }
          }
          let(:Authorization) { "Bearer token=tatayoyo}" }

          run_test! do |response|
            expect(response.status).to eq(404)
            result = JSON.parse(response.body)
            expect(result["errors"].first["source"]).to eq('Token d’API')
            expect(result["errors"].first["message"]).to eq('n’existe pas ou est invalide')
          end
        end
      end
    end
  end

  describe 'show' do
    path '/api/v1/landings/{id}' do
      get 'Page formulaire' do
        tags 'Landings'
        description 'Affiche le détail d’une page formulaire'
        parameter name: :id, in: :path, type: :string
        produces 'application/json'

        response '200', 'Page formulaire trouvée' do
          schema type: :object,
                 properties: {
                   data: {
                     '$ref' => '#/components/schemas/landing'
                   },
                   metadata: {
                     type: :object,
                     properties: {
                       total_themes: {
                         type: :integer,
                         description: 'Nombre de thèmes liée à la page formulaire.'
                       }
                     }
                   }
                 }

          let(:Authorization) { "Bearer token=#{find_token(institution)}" }
          let(:id) { landing_01.id }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = JSON.parse(response.body)
            expect(result.size).to eq(2)

            result_landing = result['data']
            expect(result_landing.keys).to match_array(["id", "title", "slug", "partner_url", "iframe_category", "landing_themes"])
            expect(result_landing["title"]).to eq('DINUM recrutement')
            expect(result_landing["landing_themes"].size).to eq(2)
          end
        end
      end
    end
  end
end
