# frozen_string_literal: true

require 'rails_helper'
require 'api_helper'
# Nécessaire pour que la constante Api::BasicError soit initialisée
require 'api/base'

describe DiagnosisCreation::CreateOrUpdateDiagnosis do
  describe 'call' do
    # the subject has to be called as a block (expect{create_or_update_diagnosis}) for raise matchers to work correctly.
    subject(:create_or_update_diagnosis) { described_class.new(params, diagnosis).call }

    let(:advisor) { create :user }
    let(:params) { { advisor: advisor, facility_attributes: facility_params } }

    context 'with new diagnosis' do
      let(:diagnosis) { nil }

      context 'with invalid facility data' do
        let(:facility_params) { { invalid: 'value' } }

        it do
          expect{ create_or_update_diagnosis }.to raise_error ActiveModel::UnknownAttributeError
        end
      end

      context 'with a facility siret' do
        let(:siret) { '12345678901234' }
        let(:facility_params) { { siret: siret } }
        let!(:intermediary_result) { DiagnosisCreation::CreateOrUpdateFacilityAndCompany.new(siret) }

        before do
          allow(DiagnosisCreation::CreateOrUpdateFacilityAndCompany).to receive(:new).with(siret) { intermediary_result }
        end

        context 'when ApiEntreprise accepts the SIRET' do
          before do
            allow(intermediary_result).to receive(:call) {
              {
                facility: create(:facility, siret: siret),
              errors: {}
              }
            }
          end

          it 'fetches info for ApiEntreprise and creates the diagnosis' do
            expect(create_or_update_diagnosis[:diagnosis]).to be_valid
          end
        end

        context 'when Api returns a standard error' do
          before do
            allow(intermediary_result).to receive(:call) { raise Api::BasicError, 'some error message' }
          end

          it 'returns the message in diagnosis errors' do
            expect(create_or_update_diagnosis[:errors]).to eq({ basic_errors: "some error message" })
          end
        end

        context 'when ApiEntreprise returns a technical error' do
          before do
            allow(intermediary_result).to receive(:call) { raise Api::TechnicalError.new(api: "api-apientreprise-entreprise-base", severity: "major"), 'some error message' }
          end

          it 'returns the message in the errors' do
            expect(create_or_update_diagnosis[:diagnosis]).not_to be_valid
            expect(create_or_update_diagnosis[:errors]).to eq({ major_api_error: { "api-apientreprise-entreprise-base" => "some error message" } })
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
          diagnosis = create_or_update_diagnosis[:diagnosis]
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
          expect{ create_or_update_diagnosis }.to raise_error ActiveModel::UnknownAttributeError
        end
      end

      context 'with a facility siret' do
        let(:siret) { '12345678901234' }
        let(:facility_params) { { siret: siret } }
        let!(:intermediary_result) { DiagnosisCreation::CreateOrUpdateFacilityAndCompany.new(siret) }

        context 'when ApiEntreprise accepts the SIRET' do
          before do
            allow(intermediary_result).to receive(:call) { raise Api::BasicError.new(:facility_commune_not_found) }
          end

          it 'fetches info for ApiEntreprise and creates the diagnosis' do
            expect(create_or_update_diagnosis[:diagnosis]).to be_valid
          end

          it 'doesnt change diagnosis step' do
            expect { create_or_update_diagnosis }.not_to change(diagnosis, :step)
          end
        end

        context 'when ApiEntreprise returns a standard error' do
          before do
            allow(Api::Base).to receive(:new)
            allow(intermediary_result).to receive(:call) {
  {
    facility: create(:facility, siret: siret),
              errors: {}
  }
}
          end

          xit 'returns the message in the errors' do
            expect(create_or_update_diagnosis[:errors]).to eq({ standard: "some error message" })
          end
        end
      end
    end
  end
end
