# frozen_string_literal: true

require 'rails_helper'

describe DiagnosisHelper do
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

      it { is_expected.to eq 'active completed' }
    end

    context 'displayed step > current_page_step && displayed step > diagnosis_step' do
      let(:current_page_step) { 1 }
      let(:diagnosis_step) { 1 }

      it { is_expected.to be_nil }
    end
  end
end
