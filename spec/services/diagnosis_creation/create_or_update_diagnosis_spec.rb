# frozen_string_literal: true

require 'rails_helper'
# Nécessaire pour que la constante Api::BasicError soit initialisée
require 'api/base'

describe DiagnosisCreation::CreateOrUpdateDiagnosis do
  describe 'call' do
    # the subject has to be called as a block (expect{created_or_updated_diagnosis}) for raise matchers to work correctly.
    subject(:created_or_updated_diagnosis) { described_class.new(params, diagnosis).call }

    let(:advisor) { create :user }
    let(:params) { { advisor: advisor, facility_attributes: facility_params } }

    context 'with new diagnosis' do
      let(:diagnosis) { nil }

      context 'with invalid facility data' do
        let(:facility_params) { { invalid: 'value' } }

        it do
          expect{ created_or_updated_diagnosis }.to raise_error ActiveModel::UnknownAttributeError
        end
      end

      context 'with a facility siret' do
        let(:siret) { '12345678901234' }
        let(:facility_params) { { siret: siret } }

        context 'when ApiEntreprise accepts the SIRET' do
          before do
            allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { create(:facility, siret: siret) }
          end

          it 'fetches info for ApiEntreprise and creates the diagnosis' do
            expect(created_or_updated_diagnosis[:diagnosis]).to be_valid
          end
        end

        context 'when Api returns a standard error' do
          before do
            allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { raise Api::BasicError, 'some error message' }
          end

          it 'returns the message in diagnosis errors' do
            expect(created_or_updated_diagnosis[:errors]).to eq({ standard: [{ error: 'some error message' }] })
          end
        end

        context 'when ApiEntreprise returns a technical error' do
          before do
            allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { raise Api::TechnicalError.new(api: "api-apientreprise-entreprise-base"), 'some error message' }
          end

          it 'returns the message in the errors' do
            expect(created_or_updated_diagnosis[:diagnosis]).not_to be_valid
            expect(created_or_updated_diagnosis[:errors]).to eq({ major: [{ "Api Entreprise - Entreprise" => { error: "some error message" } }] })
          end
        end
      end

      context 'with manual facility info' do
        let(:insee_code) { '78586' }
        let(:facility_params) { { insee_code: insee_code, company_attributes: { name: 'Boucherie Sanzot' } } }

        before do
          city_json = JSON.parse(file_fixture('geo_api_communes_78586.json').read)
          allow(ApiGeo::Query).to receive(:city_with_code).with(insee_code) { city_json }
        end

        it 'creates a new diagnosis without siret' do
          diagnosis = created_or_updated_diagnosis[:diagnosis]
          expect(diagnosis).to be_valid
          expect(diagnosis.company.name).to eq 'Boucherie Sanzot'
        end
      end
    end

    context 'with existing diagnosis' do
      let(:diagnosis) { create :diagnosis, step: :needs }

      context 'with invalid facility data' do
        let(:facility_params) { { invalid: 'value' } }

        it do
          expect{ created_or_updated_diagnosis }.to raise_error ActiveModel::UnknownAttributeError
        end
      end

      context 'with a facility siret' do
        let(:siret) { '12345678901234' }
        let(:facility_params) { { siret: siret } }

        context 'when ApiEntreprise accepts the SIRET' do
          before do
            allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { create(:facility, siret: siret) }
          end

          it 'fetches info for ApiEntreprise and creates the diagnosis' do
            expect(created_or_updated_diagnosis[:diagnosis]).to be_valid
          end

          it 'doesnt change diagnosis step' do
            expect { created_or_updated_diagnosis }.not_to change(diagnosis, :step)
          end
        end

        context 'when ApiEntreprise returns a standard error' do
          before do
            allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { raise Api::BasicError, 'some error message' }
          end

          it 'returns the message in the errors' do
            expect(created_or_updated_diagnosis[:errors]).to eq({ standard: [{ error: 'some error message' }] })
          end
        end
      end
    end
  end
end
