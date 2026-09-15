require "rails_helper"
require 'swagger_helper'

RSpec.describe "Solicitations qualifications API" do
  let(:institution) { create(:institution) }
  let(:Authorization) { "Bearer token=#{find_qualification_token(institution)}" }
  let!(:solicitation) { create(:solicitation) }

  describe 'update' do
    path '/api/v1/solicitations/qualifications' do
      put 'Qualification des sollicitations' do
        tags 'Sollicitations'
        description 'Enregistre le verdict de qualification pour un lot de 100 sollicitations maximum.'
        operationId 'updateSolicitationsQualifications'
        consumes 'application/json'
        produces 'application/json'
        parameter name: :qualifications, in: :body, schema: {
          type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              qualified: { type: :boolean },
              details: { type: :string, description: 'Motif, attendu lorsque la sollicitation est rejetée.' }
            },
            required: [ 'id', 'qualified' ]
          }
        }

        response '204', 'Toutes les qualifications ont été prises en compte' do
          let(:qualifications) { [{ id: solicitation.id, qualified: true }] }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 204 response' do |example|
            expect(response).to have_http_status(:no_content)
            expect(solicitation.reload).to be_qualified
          end
        end

        response '207', 'Erreur partielle' do
          schema type: :array,
                 items: { '$ref': "#/components/schemas/qualification_result" }
          let(:qualifications) { [{ id: solicitation.id, qualified: true }, { id: 0, qualified: false }] }

          run_test! do |response|
            expect(response.parsed_body).to eq([
              { 'id' => solicitation.id, 'status' => 200 },
              { 'id' => 0, 'status' => 400, 'message' => I18n.t('api_pde.errors.not_qualifiable') }
            ])
            expect(solicitation.reload).to be_qualified
          end
        end

        response '400', 'Format de requête invalide' do
          schema errors: {
            type: :array,
            items: { '$ref': "#/components/schemas/error" }
          }
          let(:qualifications) { [] }

          run_test! do |response|
            expect(response.parsed_body['errors'].first['source']).to eq('Format de la requête')
          end
        end

        response '403', 'Token sans le scope de qualification' do
          schema errors: {
            type: :array,
            items: { '$ref': "#/components/schemas/error" }
          }
          let(:Authorization) { "Bearer token=#{find_token(institution)}" }
          let(:qualifications) { [{ id: solicitation.id, qualified: true }] }

          run_test! do |response|
            expect(response.parsed_body['errors'].first['source']).to eq('Accès refusé')
            expect(solicitation.reload.qualified).to be_nil
          end
        end
      end
    end
  end

  describe 'behaviour' do
    let(:headers) do
      {
        'Authorization' => "Bearer token=#{find_qualification_token(institution)}",
        'CONTENT_TYPE' => 'application/json'
      }
    end

    def put_qualifications(payload)
      put "/api/v1/solicitations/qualifications", params: payload.to_json, headers: headers
    end

    it 'stores the rejection details' do
      put_qualifications([{ id: solicitation.id, qualified: false, details: "Hors périmètre" }])

      expect(response).to have_http_status(:no_content)
      expect(solicitation.reload).to have_attributes(qualified: false, qualification_details: "Hors périmètre")
      expect(solicitation.qualified_at).to be_present
    end

    it 'is idempotent' do
      put_qualifications([{ id: solicitation.id, qualified: true }])
      put_qualifications([{ id: solicitation.id, qualified: false, details: "Finalement non" }])

      expect(response).to have_http_status(:no_content)
      expect(solicitation.reload).to have_attributes(qualified: false, qualification_details: "Finalement non")
    end

    it 'rejects a batch above the maximum size' do
      payload = Array.new(Api::V1::Solicitations::QualificationsController::MAX_BATCH_SIZE + 1) { { id: solicitation.id, qualified: true } }

      put_qualifications(payload)

      expect(response).to have_http_status(:bad_request)
      expect(solicitation.reload.qualified).to be_nil
    end

    it 'rejects an item without a verdict' do
      put_qualifications([{ id: solicitation.id }])

      expect(response).to have_http_status(:multi_status)
      expect(response.parsed_body).to eq([
        { 'id' => solicitation.id, 'status' => 400, 'message' => I18n.t('api_pde.errors.not_qualifiable') }
      ])
    end

    it 'rejects an item whose verdict is not a real boolean' do
      put_qualifications([{ id: solicitation.id, qualified: 'maybe' }])

      expect(response).to have_http_status(:multi_status)
      expect(response.parsed_body).to eq([
        { 'id' => solicitation.id, 'status' => 400, 'message' => I18n.t('api_pde.errors.not_qualifiable') }
      ])
      expect(solicitation.reload.qualified).to be_nil
    end

    it 'rejects a solicitation that is no longer in progress' do
      processed_solicitation = create(:solicitation, status: :processed)

      put_qualifications([{ id: processed_solicitation.id, qualified: true }])

      expect(response).to have_http_status(:multi_status)
      expect(response.parsed_body).to eq([
        { 'id' => processed_solicitation.id, 'status' => 400, 'message' => I18n.t('api_pde.errors.not_qualifiable') }
      ])
      expect(processed_solicitation.reload.qualified).to be_nil
    end
  end
end
