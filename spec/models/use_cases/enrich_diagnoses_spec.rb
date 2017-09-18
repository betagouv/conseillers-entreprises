# frozen_string_literal: true

require 'rails_helper'

describe UseCases::EnrichDiagnoses do
  describe 'with_diagnosed_needs_count' do
    subject(:diagnoses_with_count) { described_class.with_diagnosed_needs_count diagnoses }

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

  describe 'with_selected_assistances_experts_count' do
    subject(:diagnoses_with_count) { described_class.with_selected_assistances_experts_count diagnoses }

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
