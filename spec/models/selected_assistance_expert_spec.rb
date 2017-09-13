# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelectedAssistanceExpert, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :diagnosed_need
      is_expected.to belong_to :assistance_expert
      is_expected.to validate_presence_of :diagnosed_need
      is_expected.to validate_presence_of :assistance_expert
    end
  end

  describe 'scopes' do
    describe 'of_diagnoses' do
      subject { SelectedAssistanceExpert.of_diagnoses [diagnosis] }

      let(:diagnosis) { create :diagnosis }
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }
      let(:selected_assistance_expert) { create :selected_assistance_expert, diagnosed_need: diagnosed_need }

      before do
        create :diagnosed_need, diagnosis: diagnosis
        create :selected_assistance_expert
      end

      it { is_expected.to eq [selected_assistance_expert] }
    end
  end
end
