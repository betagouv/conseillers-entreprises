# frozen_string_literal: true

require 'rails_helper'

describe ExpertsHelper, type: :helper do
  describe 'expert_button_classes' do
    subject { helper.expert_button_classes(classes_array) }

    context 'empty array' do
      let(:classes_array) { [] }

      it { is_expected.to eq %w[ui button tiny] }
    end

    context 'other array' do
      let(:classes_array) { %w[blue] }

      it { is_expected.to eq %w[ui button tiny blue] }
    end
  end
end
