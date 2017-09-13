# frozen_string_literal: true

require 'rails_helper'

describe UseCases::GetDiagnoses do
  describe 'for_user' do
    subject(:diagnoses_hash) { described_class.for_user user }

    let(:user) { create :user }

    context 'no diagnoses' do
      it { is_expected.to eq in_progress: [], completed: [] }
    end

    context 'several diagnoses' do
      let(:visit) { create :visit, advisor: user }
      let!(:in_progress_diagnosis) { create :diagnosis, step: 1, visit: visit }
      let!(:completed_diagnosis) { create :diagnosis, step: 5, visit: visit }

      before do
        allow(Diagnosis).to receive(:enrich_with_diagnosed_needs_count) { [completed_diagnosis] }
        allow(Diagnosis).to receive(:enrich_with_selected_assistances_experts_count) { [completed_diagnosis] }
      end

      it do
        expect(diagnoses_hash[:in_progress]).to eq [in_progress_diagnosis]
        expect(diagnoses_hash[:completed].first.id).to eq completed_diagnosis.id
      end
    end
  end
end
