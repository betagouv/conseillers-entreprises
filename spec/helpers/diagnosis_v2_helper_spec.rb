# frozen_string_literal: true

require 'rails_helper'

describe DiagnosisV2Helper, type: :helper do
  describe 'classes_for_step' do
    subject { helper.classes_for_step(displayed_step, current_step) }

    let(:displayed_step) { 2 }

    context 'displayed step < current_step' do
      let(:current_step) { 3 }

      it { is_expected.to eq 'completed' }
    end

    context 'displayed step = current_step' do
      let(:current_step) { 2 }

      it { is_expected.to eq 'active' }
    end

    context 'displayed step > current_step' do
      let(:current_step) { 1 }

      it { is_expected.to be_nil }
    end
  end
end
