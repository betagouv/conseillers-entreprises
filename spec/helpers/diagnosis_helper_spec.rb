# frozen_string_literal: true

require 'rails_helper'

describe DiagnosisHelper, type: :helper do
  describe 'html_classes_for_step' do
    subject { helper.html_classes_for_step(displayed_step, current_page_step, diagnosis_step) }

    let(:displayed_step) { 2 }

    context 'displayed step < diagnosis step' do
      let(:current_page_step) { 3 }
      let(:diagnosis_step) { 3 }

      it { is_expected.to eq 'completed' }
    end

    context 'displayed step = current step && displayed step >= diagnosis step' do
      let(:current_page_step) { 2 }
      let(:diagnosis_step) { 2 }

      it { is_expected.to eq 'active' }
    end

    context 'displayed step = current_page_step && displayed step < diagnosis_step' do
      let(:current_page_step) { 2 }
      let(:diagnosis_step) { 3 }

      it { is_expected.to eq 'completed active' }
    end

    context 'displayed step > current_page_step && displayed step > diagnosis_step' do
      let(:current_page_step) { 1 }
      let(:diagnosis_step) { 1 }

      it { is_expected.to be_nil }
    end
  end

  describe 'assistances_experts_localized' do
    subject do
      helper.assistances_experts_localized(diagnosed_need: diagnosed_need,
                                           assistances_experts_of_location: assistances_experts_of_location)
    end

    let(:question) { create :question }
    let(:assistance) { create :assistance, question: question }
    let(:diagnosed_need) { create :diagnosed_need, question: question }

    context 'assistances_experts are the same' do
      let(:assistances_experts_of_location) { create_list :assistance_expert, 2, assistance: assistance }

      it { is_expected.to eq assistances_experts_of_location }
    end

    context 'assistances_experts are quite different' do
      let(:assistances_experts_of_location) { create_list :assistance_expert, 2, assistance: assistance }

      before do
        other_assistances = create_list :assistance, 2, question: question
        create_list :assistance_expert, 2, assistance: other_assistances.first
        create_list :assistance_expert, 2, assistance: assistance
      end

      it { is_expected.to eq assistances_experts_of_location }
    end

    context 'assistances_experts are totally different' do
      let(:assistances_experts_of_location) { create_list :assistance_expert, 2 }

      it { is_expected.to be_empty }
    end
  end
end
