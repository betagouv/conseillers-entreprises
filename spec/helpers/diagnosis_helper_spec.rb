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

  describe 'diagnosis_matches_count' do
    subject { helper.diagnosis_matches_count }

    let(:diagnosis) { create :diagnosis }

    before do
      create :match, diagnosed_need: diagnosed_need
      create :match, diagnosed_need: diagnosed_need
      create :match, diagnosed_need: diagnosed_need2

      @diagnosis = diagnosis
    end

    context 'no match' do
      let(:diagnosed_need) { create :diagnosed_need }
      let(:diagnosed_need2) { create :diagnosed_need }

      it { is_expected.to eq 0 }
    end

    context 'three matches' do
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }
      let(:diagnosed_need2) { create :diagnosed_need, diagnosis: diagnosis }

      it { is_expected.to eq 3 }
    end
  end
end
