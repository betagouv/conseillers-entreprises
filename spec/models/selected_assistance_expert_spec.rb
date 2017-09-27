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
    describe 'not_viewed' do
      subject { SelectedAssistanceExpert.not_viewed }

      let(:selected_assistance_expert) { create :selected_assistance_expert, expert_viewed_page_at: nil }

      before { create :selected_assistance_expert, expert_viewed_page_at: 2.days.ago }

      it { is_expected.to eq [selected_assistance_expert] }
    end

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

    describe 'with_status' do
      let!(:selected_ae_with_status_quo) { create :selected_assistance_expert, status: :quo }
      let!(:selected_ae_taken_care_of) { create :selected_assistance_expert, status: :taking_care }
      let!(:selected_ae_with_status_done) { create :selected_assistance_expert, status: :done }
      let!(:selected_ae_not_for_expert) { create :selected_assistance_expert, status: :not_for_me }

      it do
        expect(SelectedAssistanceExpert.with_status(:quo)).to eq [selected_ae_with_status_quo]
        expect(SelectedAssistanceExpert.with_status(:taking_care)).to eq [selected_ae_taken_care_of]
        expect(SelectedAssistanceExpert.with_status(:done)).to eq [selected_ae_with_status_done]
        expect(SelectedAssistanceExpert.with_status(:not_for_me)).to eq [selected_ae_not_for_expert]
      end
    end

    describe 'created_before_one_week_ago' do
      subject { SelectedAssistanceExpert.created_before_one_week_ago }

      let!(:selected_ae_created_two_weeks_ago) { create :selected_assistance_expert, created_at: 2.weeks.ago }

      before { create :selected_assistance_expert, created_at: 6.days.ago }

      it { is_expected.to match_array [selected_ae_created_two_weeks_ago] }
    end

    describe 'needing_taking_care_update' do
      subject { SelectedAssistanceExpert.needing_taking_care_update }

      let!(:selected_ae_needing_update) do
        create :selected_assistance_expert, status: :taking_care, created_at: 2.weeks.ago
      end

      before do
        create :selected_assistance_expert, created_at: 6.days.ago
        create :selected_assistance_expert, status: :quo, created_at: 2.weeks.ago
        create :selected_assistance_expert, status: :done, created_at: 2.weeks.ago
      end

      it { is_expected.to match_array [selected_ae_needing_update] }
    end

    describe 'with_no_one_in_charge' do
      subject { SelectedAssistanceExpert.with_no_one_in_charge }

      let(:abandoned_diagnosed_need) { create :diagnosed_need }
      let(:answered_diagnosed_need) { create :diagnosed_need }
      let(:other_answered_diagnosed_need) { create :diagnosed_need }

      let(:selected_aes_with_noone_in_charge) do
        create_list :selected_assistance_expert, 2, status: :quo, diagnosed_need: abandoned_diagnosed_need
      end

      before do
        create :selected_assistance_expert, status: :quo, diagnosed_need: answered_diagnosed_need
        create :selected_assistance_expert, status: :taking_care, diagnosed_need: answered_diagnosed_need

        create :selected_assistance_expert, status: :done, diagnosed_need: other_answered_diagnosed_need
        create :selected_assistance_expert, status: :not_for_me, diagnosed_need: other_answered_diagnosed_need
      end

      it { is_expected.to match_array selected_aes_with_noone_in_charge }
    end
  end
end
