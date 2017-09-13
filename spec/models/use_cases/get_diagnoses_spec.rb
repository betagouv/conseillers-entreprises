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
        allow(described_class).to receive(:diagnosed_need_count_for_diagnoses) { [completed_diagnosis] }
        allow(described_class).to receive(:selected_ae_count_for_diagnoses) { [completed_diagnosis] }
      end

      it do
        expect(diagnoses_hash[:in_progress]).to eq [in_progress_diagnosis]
        expect(diagnoses_hash[:completed].first.id).to eq completed_diagnosis.id
      end
    end
  end

  describe 'diagnosed_need_count_for_diagnoses' do
    subject(:diagnoses_with_count) { described_class.send(:diagnosed_need_count_for_diagnoses, diagnoses) }

    let(:diagnoses) { [diagnosis] }
    let(:diagnosis) { create :diagnosis }

    context 'no diagnosed need' do
      it { expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 0 }
    end

    context '2 diagnosed needs' do
      before { create_list :diagnosed_need, 2, diagnosis: diagnosis }

      it { expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 2 }
    end

    context '2 diagnosis and 3 needs' do
      let(:diagnoses) { [diagnosis, other_diagnosis] }
      let(:other_diagnosis) { create :diagnosis }

      before do
        create_list :diagnosed_need, 2, diagnosis: diagnosis
        create_list :diagnosed_need, 1, diagnosis: other_diagnosis
      end

      it do
        expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 2
        expect(diagnoses_with_count.last.diagnosed_needs_count).to eq 1
      end
    end
  end

  describe 'selected_ae_count_for_diagnoses' do
    subject(:diagnoses_with_count) { described_class.send(:selected_ae_count_for_diagnoses, diagnoses) }

    let(:diagnoses) { [diagnosis] }
    let(:diagnosis) { create :diagnosis }
    let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

    context 'no selected assistance expert' do
      it { expect(diagnoses_with_count.first.selected_assistances_experts_count).to eq 0 }
    end

    context '2 selected assistances experts' do
      before { create_list :selected_assistance_expert, 2, diagnosed_need: diagnosed_need }

      it { expect(diagnoses_with_count.first.selected_assistances_experts_count).to eq 2 }
    end

    context '2 diagnosis and 3 selected assistances experts' do
      let(:diagnoses) { [diagnosis, other_diagnosis] }
      let(:other_diagnosis) { create :diagnosis }
      let(:other_diagnosed_need) { create :diagnosed_need, diagnosis: other_diagnosis }

      before do
        create_list :selected_assistance_expert, 2, diagnosed_need: diagnosed_need
        create_list :selected_assistance_expert, 1, diagnosed_need: other_diagnosed_need
      end

      it do
        expect(diagnoses_with_count.first.selected_assistances_experts_count).to eq 2
        expect(diagnoses_with_count.last.selected_assistances_experts_count).to eq 1
      end
    end
  end
end
