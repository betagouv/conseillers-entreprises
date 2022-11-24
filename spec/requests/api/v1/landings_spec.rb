require "rails_helper"
require 'swagger_helper'

RSpec.describe "Landings API" do
  let(:institution) { create(:institution) }
  let(:Authorization) { "Bearer token=#{find_token(institution)}" }
  let(:landing_01) { create_base_landing(institution) }
  let!(:ecolo_theme) { create_ecolo_theme([landing_01]) }
  let!(:sante_theme) { create_sante_theme([landing_01]) }

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
      get 'Liste des pages d’atterrissage' do
        tags 'Page d’atterrissage'
        description 'Affiche toutes les pages d’atterrissage pour l’organisation authentifiée'
        operationId 'listLandings'
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
                         description: 'Nombre de pages d’atterrissage pour l’organisation authentifiée.'
                       }
                     }
                   }
                 }
          let!(:other_landing) { create(:landing, :api, :with_subjects) }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = JSON.parse(response.body)
            expect(result.size).to eq(2)
            expect(result['data'].size).to eq(1)

            result_item = result['data'].first
            expect(result_item.keys).to match_array(["id", "title", "slug", "partner_url", "landing_themes"])
            expect(result_item["title"]).to eq('Page d’atterrissage 01')
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

  describe 'search_by_url' do
    path '/api/v1/landings/search' do
      get 'Recherche d’une page d’atterrissage à partir de l’url de sa page d’appel' do
        tags 'Page d’atterrissage'
        description 'Afin de pouvoir tracer et quantifier les appels, nous enregistrons les url des pages des sites partenaires depuis lesquelles l’API est appelé. Ainsi, pour retrouver la page d’atterrissage devant figurer à l’url XX, vous pouvez faire une recherche via cette url.'
        operationId 'searchLanding'
        produces 'application/json'
        parameter name: :url, in: :query, type: :string, description: 'Domaine du site qui appelle l’API', required: false

        response '200', 'Page d’atterrissage trouvée' do
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
                         description: 'Nombre de thèmes liée à la page d’atterrissage.'
                       }
                     }
                   }
                 }
          let(:url) { landing_01.partner_url }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = JSON.parse(response.body)

            result_landing = result['data']
            expect(result_landing["title"]).to eq('Page d’atterrissage 01')
          end
        end

        response '404', 'Page d’atterrissage inconnue' do
          schema errors: {
            type: :array,
                 items: {
                   '$ref': "#/components/schemas/error"
                 }
          }
          let(:url) { 'une-url-fictive.fr' }

          run_test! do |response|
            expect(response.status).to eq(404)
            result = JSON.parse(response.body)
            expect(result["errors"].first["source"]).to eq('Landing')
            expect(result["errors"].first["message"]).to eq('n’existe pas ou est invalide')
          end
        end

        response '400', 'Paramètres vides' do
          schema errors: {
            type: :array,
                 items: {
                   '$ref': "#/components/schemas/error"
                 }
          }

          run_test! do |response|
            expect(response.status).to eq(400)
            result = JSON.parse(response.body)
            expect(result["errors"].first["source"]).to eq('paramètres de requête')
            expect(result["errors"].first["message"]).to eq('malformés ou inconnus')
          end
        end
      end
    end
  end

  describe 'show' do
    path '/api/v1/landings/{id}' do
      get 'Page d’atterrissage' do
        tags 'Page d’atterrissage'
        description 'Affiche le détail d’une page d’atterrissage et la liste de ses thèmes'
        operationId 'showLanding'
        parameter name: :id, in: :path, type: :string, description: 'identifiant de la page', required: true
        produces 'application/json'

        response '200', 'Page d’atterrissage trouvée' do
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
                         description: 'Nombre de thèmes liée à la page d’atterrissage.'
                       }
                     }
                   }
                 }

          let(:id) { landing_01.id }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = JSON.parse(response.body)
            expect(result.size).to eq(2)

            result_landing = result['data']
            expect(result_landing.keys).to match_array(["id", "title", "slug", "partner_url", "landing_themes"])
            expect(result_landing["title"]).to eq('Page d’atterrissage 01')
            expect(result_landing["landing_themes"].size).to eq(2)
          end
        end
      end
    end
  end
end
