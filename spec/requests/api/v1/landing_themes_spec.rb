require "rails_helper"
require 'swagger_helper'

RSpec.describe "Landing Themes API", type: :request do
  let(:institution) { create(:institution) }
  let(:Authorization) { "Bearer token=#{find_token(institution)}" }
  let(:landing_01) { create_base_landing(institution) }
  let!(:ecolo_theme) { create_ecolo_theme([landing_01]) }
  let!(:dechet_subject) { create_dechet_subject(ecolo_theme) }
  let!(:eau_subject) { create_eau_subject(ecolo_theme) }

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
    path '/api/v1/landing_themes' do
      get 'Liste des thèmes' do
        tags 'Thèmes'
        description 'Affiche tous les thèmes pour l’organisation authentifiée'
        produces 'application/json'

        response '200', 'ok' do
          schema type: :object,
                 properties: {
                   data: {
                     type: :array,
                     items: {
                       '$ref': "#/components/schemas/landing_theme"
                     }
                   },
                   metadata: {
                     type: :object,
                     properties: {
                       total_results: {
                         type: :integer,
                         description: 'Nombre de thèmes pour l’organisation authentifiée.'
                       }
                     }
                   }
                 }

          let(:landing_02) { create(:landing, :api, institution: institution, title: 'Page d’atterrissage 02', slug: 'page-atterrissage-02') }
          let!(:sante_theme) { create_sante_theme([landing_02]) }
          let!(:recrutement_theme) { create_rh_theme([landing_01]) }
          let!(:landing_temoin) { create(:landing, :api, :with_subjects) }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = JSON.parse(response.body)
            expect(result.size).to eq(2)
            expect(result['data'].size).to eq(3)
          end
        end
      end
    end
  end

  describe 'show' do
    path '/api/v1/landing_themes/{id}' do
      get 'Page thème' do
        tags 'Thèmes'
        description 'Affiche le détail d’un thème et la liste de ses sujets'
        parameter name: :id, in: :path, type: :string
        produces 'application/json'

        response '200', 'Page thème trouvée' do
          schema type: :object,
                 properties: {
                   data: {
                     '$ref' => '#/components/schemas/landing_theme'
                   },
                   metadata: {
                     type: :object,
                     properties: {
                       total_themes: {
                         type: :integer,
                         description: 'Nombre de sujets liés aux thèmes.'
                       }
                     }
                   }
                 }

          let(:id) { ecolo_theme.id }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = JSON.parse(response.body)
            expect(result.size).to eq(2)

            result_item = result['data']
            expect(result_item.keys).to match_array(["id", "title", "slug", "description", "landing_subjects"])
            expect(result_item["title"]).to eq('Environnement, transition écologique & RSE')
            expect(result_item["landing_subjects"].size).to eq(2)
          end
        end
      end
    end
  end
end
