# frozen_string_literal: true

require 'rails_helper'
describe DiagnosisCreation::PrepareDiagnosis do
  describe 'call' do
    let(:user) { create :user }
    let(:api_url) { "https://api-adresse.data.gouv.fr/search/?q=matignon&type=municipality" }
    let(:some_params) do
      {
        advisor: user,
      facility_attributes: facility_attributes,
      solicitation: solicitation
      }
    end
    let(:facility_attributes) { { siret: solicitation.siret } }
    let!(:intermediary_result) { DiagnosisCreation::CreateOrUpdateDiagnosis.new(some_params, diagnosis) }
    let!(:diagnosis_steps) { DiagnosisCreation::Steps.new(diagnosis) }

    before do
      allow(solicitation).to receive(:may_prepare_diagnosis?).and_return(true)
      # suivant le contexte, ce ne sont pas toujours les memes arguments qui sont envoyés
      allow(DiagnosisCreation::CreateOrUpdateDiagnosis).to receive(:new).with(some_params, diagnosis) { intermediary_result }
      allow(DiagnosisCreation::CreateOrUpdateDiagnosis).to receive(:new).with(some_params, nil) { intermediary_result }
      allow(intermediary_result).to receive(:call) { diagnosis }

      allow(DiagnosisCreation::Steps).to receive(:new).with(diagnosis) { diagnosis_steps }
      allow(diagnosis_steps).to receive(:prepare_needs_from_solicitation) { prepare_needs }
      allow(diagnosis_steps).to receive(:prepare_happened_on_from_solicitation)
      allow(diagnosis_steps).to receive(:prepare_visitee_from_solicitation)
      allow(diagnosis_steps).to receive(:prepare_matches_from_solicitation)
      stub_request(:get, api_url).to_return(
        body: file_fixture('api_adresse_search_municipality.json')
      )
      described_class.new(solicitation, user).call
    end

    context 'solicitation with siret' do
      let(:solicitation) { create :solicitation }

      context 'all is well' do
        let(:diagnosis) { create :diagnosis, solicitation: solicitation, advisor: user }
        let(:prepare_needs) { [] }

        it do
          expect(solicitation.diagnosis).not_to be_nil
          expect(solicitation.prepare_diagnosis_errors).to be_empty
        end
      end

      context 'creation fails' do
        let(:diagnosis) { Diagnosis.create(facility: nil, advisor: user) }
        let(:prepare_needs) { [] }

        it do
          expect(solicitation.diagnosis).to be_nil
          expect(solicitation.prepare_diagnosis_errors.details).to eq({ facility: [{ error: :blank }] })
        end
      end

      context 'preparation fails' do
        let(:diagnosis) { create :diagnosis, solicitation: solicitation, advisor: user }
        let(:prepare_needs) { diagnosis.errors.add(:needs, :some_failure) }

        it do
          expect(solicitation.diagnosis).to be_nil
          expect(solicitation.prepare_diagnosis_errors.details).to eq({ needs: [{ error: :some_failure }] })
        end
      end
    end

    context 'solicitation without siret' do
      let(:location) { "matignon" }
      let(:solicitation) { create :solicitation, siret: nil, location: location }
      let(:facility_attributes) { { insee_code: '22143', company_attributes: { name: solicitation.full_name } } }

      context 'all is well' do
        let(:diagnosis) { create :diagnosis, solicitation: solicitation, advisor: user }
        let(:prepare_needs) { [] }

        it do
          expect(solicitation.diagnosis).not_to be_nil
          expect(solicitation.prepare_diagnosis_errors).to be_empty
        end
      end

      context 'creation fails' do
        let(:diagnosis) { Diagnosis.create(facility: nil, advisor: user) }
        let(:prepare_needs) { [] }

        it do
          expect(solicitation.diagnosis).to be_nil
          expect(solicitation.prepare_diagnosis_errors.details).to eq({ facility: [{ error: :blank }] })
        end
      end

      context 'preparation fails' do
        let(:diagnosis) { create :diagnosis, solicitation: solicitation, advisor: user }
        let(:prepare_needs) { diagnosis.errors.add(:needs, :some_failure) }

        it do
          expect(solicitation.diagnosis).to be_nil
          expect(solicitation.prepare_diagnosis_errors.details).to eq({ needs: [{ error: :some_failure }] })
        end
      end
    end
  end
end
