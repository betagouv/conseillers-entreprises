require "rails_helper"
require 'swagger_helper'

RSpec.describe "Solicitations API", type: :request do
  let(:institution) { create(:institution) }
  let(:Authorization) { "Bearer token=#{find_token(institution)}" }
  let(:landing_01) { create_base_landing(institution) }
  let!(:rh_theme) { create_rh_theme([landing_01]) }
  let!(:recrutement_subject) { create_recrutement_subject(rh_theme) }
  let!(:cadre_question) { create_cadre_question(recrutement_subject.subject) }
  let!(:apprentissage_question) { create_apprentissage_question(recrutement_subject.subject) }

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

  describe 'create' do
    path '/api/v1/solicitations' do
      post 'Créer une sollicitation' do
        tags 'Sollicitation'
        description 'Crée une sollicitation liée à un sujet, en provenance d’une organisation.'
        consumes 'application/json'
        parameter name: :solicitation_params, in: :body, schema: { '$ref': '#/components/schemas/new_solicitation' }

        response '200', 'ok' do
          schema type: :object,
                 properties: {
                   data: {
                     type: :array,
                     items: {
                       '$ref': "#/components/schemas/solicitation_created"
                     }
                   },
                   metadata: {
                     type: :object,
                     properties: {}
                   }
                 }
          let(:siret) { 13002526500013 }
          let(:solicitation_params) {
  {
    landing_id: landing_01.id,
  landing_subject_id: recrutement_subject.id,
  description: "ma demande",
  full_name: "Hubertine Auclerc",
  phone_number: '0606060606',
  email: 'hubertine@example.com',
  siret: siret,
  questions_additionnelles: [
    { question_id: cadre_question.id, answer: true },
    { question_id: apprentissage_question.id, answer: false },
  ],
  api_calling_url: 'http://mon-partenaire.fr/page-recrutement'
  }
}
          let(:token) { '1234' }
          let(:api_entreprise_url) { "https://entreprise.api.gouv.fr/v2/etablissements/#{siret}?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=#{token}" }

          before do |example|
            ENV['API_ENTREPRISE_TOKEN'] = token
            stub_request(:get, api_entreprise_url).to_return(
              body: file_fixture('api_entreprise_get_etablissement.json')
            )
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            data = JSON.parse(response.body)['data']

            expect(data['uuid']).not_to be_nil
            expect(data['code_region']).to eq(11)
            expect(data['landing_subject']).to eq("Recruter un ou plusieurs salariés")
            expect(data['status']).to eq('in_progress')
            expect(data['questions_additionnelles']).to match_array([
              { 'question_id' => cadre_question.id, 'question_label' => I18n.t(:label, scope: [:activerecord, :attributes, :additional_subject_questions, cadre_question.key]), 'answer' => true },
              { 'question_id' => apprentissage_question.id, 'question_label' => I18n.t(:label, scope: [:activerecord, :attributes, :additional_subject_questions, apprentissage_question.key]), 'answer' => false },
            ])
            expect(data['api_calling_url']).to eq('http://mon-partenaire.fr/page-recrutement')
          end

          it 'creates a solicitation' do
            solicitation = Solicitation.last
            pp solicitation

            expect(solicitation).to be_persisted
            expect(solicitation.code_region).to eq(11)
            expect(solicitation.api_calling_url).to eq('http://mon-partenaire.fr/page-recrutement')
            expect(solicitation.status).to eq('in_progress')
            expect(solicitation.institution_filters.size).to eq(2)
          end
        end

        # response '404' do
        # end
      end
    end
  end
end
