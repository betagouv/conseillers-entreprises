# frozen_string_literal: true

require 'rails_helper'

describe UseCases::GetDiagnoses do
  describe 'for_user' do
    subject { described_class.for_user user }

    let(:user) { create :user }

    context 'no diagnoses' do
      it { is_expected.to eq in_progress: [], completed: [] }
    end

    context 'several diagnoses' do
      let(:visit) { create :visit, advisor: user }
      let(:in_progress_diagnosis) { create :diagnosis, step: 1, visit: visit }
      let(:completed_diagnosis) { create :diagnosis, step: 5, visit: visit }

      it { is_expected.to eq in_progress: [in_progress_diagnosis], completed: [completed_diagnosis] }
    end
  end
end
