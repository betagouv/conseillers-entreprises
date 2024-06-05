require "rails_helper"
require 'swagger_helper'

RSpec.describe "Landing Subjects API" do
  let(:institution) { create(:institution) }
  let(:Authorization) { "Bearer token=#{find_token(institution)}" }
  let(:landing_01) { create_base_landing(institution) }
  let(:landing_id) { landing_01.id }
  let!(:rh_theme) { create_rh_theme([landing_01]) }
  let!(:recrutement_subject) { create_recrutement_subject(rh_theme) }
  let!(:formation_subject) { create_formation_subject(rh_theme) }
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

  describe 'index' do
    path '/api/v1/landings/{landing_id}/landing_subjects' do
      get 'Liste des sujets' do
        tags 'Sujets'
        description 'Affiche tous les sujets d’une page d’atterrissage'
        operationId 'listLandingSubjects'
        parameter name: :landing_id, in: :path, type: :integer, description: 'identifiant de la page d’atterrissage', required: true
        produces 'application/json'

        response '200', 'ok' do
          schema type: :object,
                 properties: {
                   data: {
                     type: :array,
                     items: {
                       '$ref': "#/components/schemas/landing_subject"
                     }
                   },
                   metadata: {
                     type: :object,
                     properties: {
                       total_results: {
                         type: :integer,
                         description: 'Nombre de sujets de la page d’atterrissage.'
                       }
                     }
                   }
                 }

          let(:landing_02) { create(:landing, :api, institution: institution, title: 'Page d’atterrissage 02', slug: 'page-atterrissage-02') }
          let!(:sante_theme) { create_sante_theme([landing_02]) }
          let!(:sante_sujet) { create_obligations_sante_subject(sante_theme) }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = response.parsed_body
            expect(result.size).to eq(2)
            expect(result['data'].size).to eq(2)
          end
        end
      end
    end
  end

  describe 'search_by_slug' do
    path '/api/v1/landings/{landing_id}/landing_subjects/search' do
      get 'Recherche d’un sujet à partir de son slug' do
        tags 'Sujets'
        description 'Recherche d’un sujet à partir de son slug, équivalent à un mot clé, pour faciliter la récupération d’un sujet spécifique.'
        operationId 'searchLandingSubject'
        produces 'application/json'
        parameter name: :landing_id, in: :path, type: :integer, description: 'identifiant de la page d’atterrissage', required: true
        parameter name: :slug, in: :query, type: :string, description: 'Slug du sujet', required: false

        response '200', 'Sujet trouvé' do
          schema type: :object,
                 properties: {
                   data: {
                     '$ref' => '#/components/schemas/landing_subject'
                   },
                   metadata: {
                     type: :object
                   }
                 }
          let(:slug) { recrutement_subject.slug }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = response.parsed_body
            expect(result.size).to eq(1)

            result_item = result['data']
            expect(result_item["title"]).to eq('Recruter un ou plusieurs salariés')
          end
        end

        response '404', 'Page d’atterrissage inconnue' do
          schema errors: {
            type: :array,
                 items: {
                   '$ref': "#/components/schemas/error"
                 }
          }
          let(:slug) { 'un-slug-fictif' }

          run_test! do |response|
            expect(response.status).to eq(404)
            result = JSON.parse(response.body)
            expect(result["errors"].first["source"]).to eq('Sujet de landing')
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
    path '/api/v1/landings/{landing_id}/landing_subjects/{id}' do
      get 'Page sujet' do
        tags 'Sujets'
        description 'Affiche le détail d’un formulaire sujet'
        operationId 'showLandingSubject'
        parameter name: :landing_id, in: :path, type: :integer, description: 'identifiant de la page d’atterrissage', required: true
        parameter name: :id, in: :path, type: :integer, description: 'identifiant du sujet', required: true
        produces 'application/json'

        response '200', 'Sujet trouvé' do
          schema type: :object,
                 properties: {
                   data: {
                     '$ref' => '#/components/schemas/landing_subject'
                   },
                   metadata: {
                     type: :object
                   }
                 }

          let(:id) { recrutement_subject.id }

          before do |example|
            opco_1 = create(:institution, :opco, name: 'OPCO OCAPIAT', logo: Logo.create(filename: 'ocapiat', name: 'Ocapiat'))
            opco_2 = create(:institution, :opco, name: 'OPCO Uniformation', logo: Logo.create(filename: 'uniformation', name: 'Uniformation'))
            opco_1.institutions_subjects.create(subject: recrutement_subject.subject)
            opco_2.institutions_subjects.create(subject: recrutement_subject.subject)

            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            result = response.parsed_body
            expect(result.size).to eq(1)

            result_item = result['data']
            expect(result_item.keys).to contain_exactly("id", "title", "slug", "landing_id", "landing_theme_id", "landing_theme_slug", "description", "description_explanation", "requires_siret", "requires_location", "questions_additionnelles", "institutions_partenaires")
            expect(result_item["title"]).to eq('Recruter un ou plusieurs salariés')
            expect(result_item["landing_theme_slug"]).to eq('recrutement-formation')
            expect(result_item["institutions_partenaires"]).to eq(["Chambre de Commerce et d'Industrie (CCI)", 'OPérateur de COmpétences (OPCO)'])
          end
        end
      end
    end
  end
end
