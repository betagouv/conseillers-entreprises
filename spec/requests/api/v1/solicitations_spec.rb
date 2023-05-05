require "rails_helper"
require 'swagger_helper'

RSpec.describe "Solicitations API" do
  let(:institution) { create(:institution, name: 'Institution Partenaire') }
  let(:Authorization) { "Bearer token=#{find_token(institution)}" }
  let(:landing_01) { create_base_landing(institution) }
  let!(:rh_theme) { create_rh_theme([landing_01]) }
  let!(:recrutement_subject) { create_recrutement_subject(rh_theme) }
  let!(:cadre_question) { create_cadre_question(recrutement_subject.subject) }
  let!(:apprentissage_question) { create_apprentissage_question(recrutement_subject.subject) }
  let(:siret) { 13002526500013 }
  let(:token) { '1234' }
  let(:api_entreprise_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{siret}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }
  let(:base_solicitation) do
    {
      landing_id: landing_01.id,
      landing_subject_id: recrutement_subject.id,
      description: "ma demande",
      full_name: "Hubertine Auclerc",
      phone_number: '0606060606',
      email: 'hubertine@example.com',
      siret: siret,
      api_calling_url: 'http://mon-partenaire.fr/page-recrutement',
      questions_additionnelles: [
        { question_id: cadre_question.id, answer: true },
        { question_id: apprentissage_question.id, answer: false },
      ],
    }
  end

  # Génération automatique des exemples dans la doc
  after do |example|
    content = example.metadata[:response][:content] || {}
    example_name = example.metadata[:response][:description].parameterize.underscore
    example_spec = {
      "application/json" => {
        examples: {
          "#{example_name}": {
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
        description 'Crée une sollicitation liée à un sujet, en provenance d’une institution.'
        operationId 'createSolicitation'
        consumes 'application/json'
        produces 'application/json'
        parameter name: :solicitation, in: :body, schema: { '$ref': '#/components/schemas/new_solicitation' }, required: true

        response '200', 'Solicitation créée' do
          schema type: :object,
                 properties: {
                   data: {
                     type: :array,
                     items: {
                       '$ref': "#/components/schemas/solicitation_created"
                     }
                   }
                 }

          let(:solicitation) { { solicitation: base_solicitation } }

          before do |example|
            opco_1 = create(:opco, name: 'OPCO OCAPIAT', logo: Logo.create(filename: 'ocapiat', name: 'Ocapiat'))
            opco_2 = create(:opco, name: 'OPCO Uniformation', logo: Logo.create(filename: 'uniformation', name: 'Uniformation'))
            opco_1.institutions_subjects.create(subject: recrutement_subject.subject)
            opco_2.institutions_subjects.create(subject: recrutement_subject.subject)

            ENV['API_ENTREPRISE_TOKEN'] = token
            stub_request(:get, api_entreprise_url).to_return(
              body: file_fixture('api_entreprise_etablissement.json')
            )
            submit_request(example.metadata)
          end

          it 'returns a valid 200 response' do |example|
            expect(response).to have_http_status(:ok)
            data = response.parsed_body['data']

            expect(data['institutions_partenaires']).to eq(["Chambre de Commerce et d'Industrie (CCI)", 'OPérateur de COmpétences (OPCO)'])
          end

          it 'creates a solicitation' do
            new_solicitation = Solicitation.last

            expect(new_solicitation).to be_persisted
            expect(new_solicitation.code_region).to eq(11)
            expect(new_solicitation.api_calling_url).to eq('http://mon-partenaire.fr/page-recrutement')
            expect(new_solicitation.status).to eq('in_progress')
            expect(new_solicitation.institution_filters.size).to eq(2)
            expect(new_solicitation.institution).to eq(institution)
          end
        end

        context 'Paramètre "Solicitation" manquant' do
          response '400', 'Paramètre "Solicitation" manquant' do
            schema errors: {
              type: :array,
                   items: {
                     '$ref': "#/components/schemas/error"
                   }
            }
            let(:solicitation) { {} }

            before do |example|
              submit_request(example.metadata)
            end

            it 'returns a 400 response' do |example|
              expect(response).to have_http_status(:bad_request)
              result = response.parsed_body

              expect(result["errors"].first["source"]).to eq('solicitation')
              expect(result["errors"].first["message"]).to eq('le paramètre est manquant')
            end
          end
        end

        context 'Url d’appel manquante' do
          response '422', 'Url d’appel manquante' do
            schema errors: {
              type: :array,
                    items: {
                      '$ref': "#/components/schemas/error"
                    }
            }
            let(:solicitation) { { solicitation: base_solicitation.except(:api_calling_url) } }

            before do |example|
              ENV['API_ENTREPRISE_TOKEN'] = token
              stub_request(:get, api_entreprise_url).to_return(
                body: file_fixture('api_entreprise_etablissement.json')
              )
              submit_request(example.metadata)
            end

            it 'returns calling_url error' do
              expect(response).to have_http_status(:unprocessable_entity)
              result = response.parsed_body
              expect(result["errors"].first["source"]).to eq('Url d’appel')
              expect(result["errors"].first["message"]).to eq('doit être rempli(e)')
            end
          end
        end

        context 'Siret invalide' do
          response '422', 'Siret invalide' do
            schema errors: {
              type: :array,
                    items: {
                      '$ref': "#/components/schemas/error"
                    }
            }
            let(:solicitation) { { solicitation: base_solicitation.merge({ siret: '12345678900011' }) } }

            before do |example|
              submit_request(example.metadata)
            end

            it 'returns siret error' do
              result = response.parsed_body
              expect(response).to have_http_status(:unprocessable_entity)
              expect(result["errors"].first["source"]).to eq('SIRET')
              expect(result["errors"].first["message"]).to eq('doit être un numéro à 14 chiffres valide')
            end
          end
        end

        context 'Questions additionnelles manquantes' do
          response '422', 'Un champs obligatoire de la solicitation manquant' do
            schema errors: {
              type: :array,
                    items: {
                      '$ref': "#/components/schemas/error"
                    }
            }
            let(:siret) { 13002526500013 }
            let(:solicitation) { { solicitation: base_solicitation.except(:questions_additionnelles) } }

            before do |example|
              ENV['API_ENTREPRISE_TOKEN'] = token
              stub_request(:get, api_entreprise_url).to_return(
                body: file_fixture('api_entreprise_etablissement.json')
              )
              submit_request(example.metadata)
            end

            it 'returns insitution_filters error' do |example|
              expect(response).to have_http_status(:unprocessable_entity)
              result = response.parsed_body
              expect(result["errors"].first["source"]).to eq('Questions additionnelles')
              expect(result["errors"].first["message"]).to eq('doit être rempli(e)')
            end
          end
        end

        context 'Mauvaises questions additionnelles' do
          response '200', 'Solicitation créée meme avec de mauvais id de questions additionnelles' do
              schema type: :object,
                     properties: {
                       data: {
                         type: :array,
                         items: {
                           '$ref': "#/components/schemas/solicitation_created"
                         }
                       }
                     }

              let(:siret) { 13002526500013 }
              let(:solicitation) do
    {
      solicitation: base_solicitation.merge({
        questions_additionnelles: [
          { question_id: 333, answer: true },
          { question_id: 444, answer: false },
        ]
      })
    }
  end

              before do |example|
                ENV['API_ENTREPRISE_TOKEN'] = token
                stub_request(:get, api_entreprise_url).to_return(
                  body: file_fixture('api_entreprise_etablissement.json')
                )
                submit_request(example.metadata)
              end

              it 'creates a solicitation' do
                new_solicitation = Solicitation.last
                expect(new_solicitation.institution_filters.first.additional_subject_question_id).to eq(cadre_question.id)
                expect(new_solicitation.institution_filters.last.additional_subject_question_id).to eq(apprentissage_question.id)
              end
            end
        end

        context 'Mauvaise landing' do
          response '422', 'Page introuvable' do
            schema errors: {
              type: :array,
                    items: {
                      '$ref': "#/components/schemas/error"
                    }
            }
            let(:siret) { 13002526500013 }
            let(:solicitation) { { solicitation: base_solicitation.merge({ landing_id: 'abc' }) } }

            before do |example|
              ENV['API_ENTREPRISE_TOKEN'] = token
              stub_request(:get, api_entreprise_url).to_return(
                body: file_fixture('api_entreprise_etablissement.json')
              )
              submit_request(example.metadata)
            end

            it 'returns insitution_filters error' do |example|
              expect(response).to have_http_status(:unprocessable_entity)
              result = response.parsed_body
              expect(result["errors"].first["source"]).to eq('Page d’atterrissage')
              expect(result["errors"].first["message"]).to eq('doit être rempli(e)')
            end
          end
        end
      end
    end
  end
end
