require "rails_helper"
require 'swagger_helper'

RSpec.describe "Subjects API" do
  let(:institution) { create(:institution) }
  let(:Authorization) { "Bearer token=#{find_token(institution)}" }
  let!(:subject_01) { create(:subject, label: "Subjet 01") }
  let!(:landing_subject_01) { create(:landing_subject, title: "Landing Subject 01", subject: subject_01) }

  describe 'index' do
    path '/api/v1/subjects' do
      get 'Liste des sujets' do
        tags 'Sujets'
        description 'Affiche tous les sujets de besoins ainsi que les sujets d’atterrissage associés.'
        operationId 'listSubjects'
        produces 'application/json'

        response '200', 'ok' do
          schema type: :object,
                 properties: {
                   data: {
                     type: :array,
                     items: {
                       '$ref': "#/components/schemas/subject"
                     }
                   },
                   metadata: {
                     type: :object,
                     properties: {
                       total_results: {
                         type: :integer,
                         description: 'Nombre de sujets.'
                       }
                     }
                   }
                 }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = response.parsed_body
            expect(result.size).to eq(2)
            expect(result['data'].size).to eq(1)

            result_item = result['data'].first
            expect(result_item.keys).to contain_exactly("id", "label", "slug", "can_be_automated", "landing_subjects")
            expect(result_item["label"]).to eq('Subjet 01')
            expect(result_item["landing_subjects"].size).to eq(1)
            expect(result_item["landing_subjects"].first["title"]).to eq("Landing Subject 01")
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
            expect(result["errors"].first["source"]).to eq('Jeton d’API')
            expect(result["errors"].first["message"]).to eq('n’existe pas ou est invalide')
          end
        end
      end
    end
  end
end
