require "rails_helper"
require 'swagger_helper'

RSpec.describe "Unqualified solicitations API" do
  let(:institution) { create(:institution) }
  let(:Authorization) { "Bearer token=#{find_qualification_token(institution)}" }
  let(:subject_recrutement) { create(:subject) }
  let!(:landing_subject) { create(:landing_subject, subject: subject_recrutement) }
  let!(:solicitation) { create(:solicitation, landing_subject: landing_subject, description: "Besoin de recruter") }

  describe 'unqualified' do
    path '/api/v1/solicitations/unqualified' do
      get 'Liste des sollicitations non qualifiées' do
        tags 'Sollicitations'
        description 'Affiche les sollicitations en cours de traitement dont la qualification n’a pas encore été renseignée.'
        operationId 'listUnqualifiedSolicitations'
        produces 'application/json'
        parameter name: :page, in: :query, type: :integer, required: false, description: 'Numéro de page (défaut 1).'
        parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Nombre de résultats par page (défaut 100, maximum 1000).'

        response '200', 'ok' do
          schema type: :object,
                 properties: {
                   count: { type: :integer, description: 'Nombre total de sollicitations non qualifiées.' },
                   solicitations: {
                     type: :array,
                     items: { '$ref': "#/components/schemas/unqualified_solicitation" }
                   }
                 }
          header 'X-Call-Id', schema: { type: :string }, description: 'Identifiant de corrélation de l’appel, à fournir lors d’une investigation.'

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = response.parsed_body

            expect(result['count']).to eq(1)
            expect(result['solicitations'].size).to eq(1)
            expect(result['solicitations'].first).to eq(
              'id' => solicitation.id,
              'subject' => subject_recrutement.id,
              'description' => "Besoin de recruter"
            )
          end
        end

        response '403', 'Token sans le scope de qualification' do
          schema errors: {
            type: :array,
            items: { '$ref': "#/components/schemas/error" }
          }
          let(:Authorization) { "Bearer token=#{find_token(institution)}" }

          run_test! do |response|
            result = response.parsed_body

            expect(result['errors'].first['source']).to eq('Accès refusé')
            expect(result['errors'].first['message']).to eq('Cette clé d’API n’a pas les droits nécessaires pour accéder à cette ressource')
          end
        end

        response '404', 'Mauvais token' do
          schema errors: {
            type: :array,
            items: { '$ref': "#/components/schemas/error" }
          }
          let(:Authorization) { "Bearer token=tatayoyo}" }

          run_test! do |response|
            expect(response.parsed_body['errors'].first['source']).to eq('Jeton d’API')
          end
        end
      end
    end
  end

  describe 'scoping and pagination' do
    let(:headers) { { 'Authorization' => "Bearer token=#{find_qualification_token(institution)}" } }

    it 'excludes already qualified and non in_progress solicitations' do
      create(:solicitation, qualified: true)
      create(:solicitation, status: :processed)

      get "/api/v1/solicitations/unqualified", headers: headers
      result = response.parsed_body

      expect(result['count']).to eq(1)
      expect(result['solicitations'].pluck('id')).to eq([solicitation.id])
    end

    it 'returns the global count regardless of pagination' do
      create_list(:solicitation, 2)

      get "/api/v1/solicitations/unqualified", params: { per_page: 1 }, headers: headers
      result = response.parsed_body

      expect(result['count']).to eq(3)
      expect(result['solicitations'].size).to eq(1)
    end

    it 'ignores an out of range per_page instead of trusting it' do
      create_list(:solicitation, 2)

      get "/api/v1/solicitations/unqualified", params: { per_page: 0 }, headers: headers
      expect(response.parsed_body['solicitations'].size).to eq(1)

      get "/api/v1/solicitations/unqualified", params: { per_page: 99_999 }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['solicitations'].size).to eq(3)
    end

    it 'paginates with the page parameter' do
      second_solicitation = create(:solicitation)

      get "/api/v1/solicitations/unqualified", params: { page: 2, per_page: 1 }, headers: headers

      expect(response.parsed_body['solicitations'].pluck('id')).to eq([second_solicitation.id])
    end

    it 'never exposes personal data' do
      identified_solicitation = create(:solicitation,
        full_name: "Jean Dupont", email: "jean.dupont@example.com",
        phone_number: "0612345678", siret: "12345678900011")

      get "/api/v1/solicitations/unqualified", headers: headers

      expect(response.parsed_body['solicitations'].first.keys).to contain_exactly('id', 'subject', 'description')
      expect(response.body).not_to include(identified_solicitation.full_name, identified_solicitation.email,
        identified_solicitation.phone_number, identified_solicitation.siret)
    end

    it 'exposes the subject of the need rather than the one of the landing subject' do
      corrected_subject = create(:subject)
      solicitation.update!(diagnosis: create(:diagnosis, needs: [build(:need, subject: corrected_subject)]))

      get "/api/v1/solicitations/unqualified", headers: headers

      expect(response.parsed_body['solicitations'].first['subject']).to eq(corrected_subject.id)
    end

    it 'returns a correlation id in the response headers' do
      get "/api/v1/solicitations/unqualified", headers: headers

      expect(response.headers['X-Call-Id']).to be_present
    end

    it 'returns a correlation id even when authentication fails' do
      get "/api/v1/solicitations/unqualified", headers: { 'Authorization' => "Bearer token=tatayoyo" }

      expect(response).to have_http_status(:not_found)
      expect(response.headers['X-Call-Id']).to be_present
    end

    it 'denies access with a revoked key' do
      # `headers` crée la clé à la volée : on la référence avant de pouvoir la révoquer.
      revoked_headers = headers
      institution.api_key.revoke

      get "/api/v1/solicitations/unqualified", headers: revoked_headers

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(solicitation.description)
    end
  end
end
