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

  describe 'defaults' do
    let(:selected_assistance_expert) { create :selected_assistance_expert }

    context 'creation' do
      it { expect(selected_assistance_expert.status).not_to be_nil }
    end

    context 'update' do
      it { expect { selected_assistance_expert.update status: nil }.to raise_error ActiveRecord::NotNullViolation }
    end
  end

  describe 'scopes' do
    describe 'of_expert' do
      subject { SelectedAssistanceExpert.of_expert expert }

      let(:expert) { create :expert }
      let(:assistance_expert) { create :assistance_expert, expert: expert }
      let(:selected_assistance_expert) { create :selected_assistance_expert, assistance_expert: assistance_expert }

      before do
        create :assistance_expert
        create :selected_assistance_expert
      end

      it { is_expected.to eq [selected_assistance_expert] }
    end

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
