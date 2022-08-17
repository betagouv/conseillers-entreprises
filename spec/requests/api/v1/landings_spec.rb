require "rails_helper"
require 'swagger_helper'

RSpec.describe "Landings API", type: :request do
  path '/api/v1/landings' do
    let(:institution) { create(:institution) }

    get 'Liste des pages formulaires' do
      tags 'Landings', 'Authentication'
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

        it 'returns a valid 201 response' do |example|
          data = JSON.parse(response.body)
          expect(data.size).to eq(1)
          expect(data).to eq([
            {
              "id" => landing_01.id,
              "iframe_category" => "integral",
              "partner_url" => 'https://www.example.com/aides',
              "slug" => landing_01.slug,
              "title" => 'Landing 01'
            }
          ])
        end

        # run_test! do |response|
        #   data = JSON.parse(response.body)
        #   expect(data.size).to eq(1)
        #   expect(data).to eq([
        #     {
        #       "id" => landing_01.id,
        #       "iframe_category" => "integral",
        #       "partner_url" => 'https://www.example.com/aides',
        #       "slug" => landing_01.slug,
        #       "title" => 'Landing 01'
        #     }
        #   ])
        # end
      end

      response '404', 'Mauvais token' do
        let(:Authorization) { "Bearer token=tatayoyo}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["errors"]).to eq("Cet objet n'a pu être trouvé")
        end
      end
    end
  end
end

# RSpec.describe "Authentication API", type: :request do
#   describe "#index" do
#     let!(:institution) { create(:institution) }

#     context "when no landing" do
#       it 'returns empty data' do
#         get "/api/v1/landings", headers: authentication_headers(institution)
#         json = JSON.parse(response.body)

#         expect(json).to eq([])
#       end
#     end

#     context "when has landings" do
#       let!(:landing_01) { create(:landing, title: 'Landing 01', institution: institution) }

#       it 'returns success' do
#         get "/api/v1/landings", headers: authentication_headers(institution)
#         json = JSON.parse(response.body)

#         expect(json).to eq([
#           {
#             "id" => landing_01.id,
#                     "iframe_category" => "integral",
#                     "partner_url" => nil,
#                     "slug" => landing_01.slug,
#                     "title" => 'Landing 01'
#           }
#         ])
#       end
#     end
#   end
# end
