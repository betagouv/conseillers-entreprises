# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SelectedAssistanceExpert, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :diagnosed_need
      is_expected.to belong_to :assistance_expert
      is_expected.to validate_presence_of :diagnosed_need
    end
  end

  describe 'audited' do
    context 'create' do
      it { expect { create :selected_assistance_expert }.to change(Audited::Audit, :count).by 1 }
    end

    context 'update status' do
      let!(:selected_assistance_expert) { create :selected_assistance_expert }

      it { expect { selected_assistance_expert.update status: :done }.to change(Audited::Audit, :count).by 1 }
    end

    context 'update attribute other than status' do
      let!(:selected_assistance_expert) { create :selected_assistance_expert }

      it do
        expect { selected_assistance_expert.update assistance_title: 'UPDATE !!' }.not_to change Audited::Audit, :count
      end
    end

    context 'destroy' do
      let!(:selected_assistance_expert) { create :selected_assistance_expert }

      it { expect { selected_assistance_expert.destroy }.to change(Audited::Audit, :count).by 1 }
    end
  end

  describe 'after_update' do
    let(:selected_assistance_expert) { create :selected_assistance_expert }

    context 'status is taking_care and going back to quo' do
      before do
        selected_assistance_expert.update status: :taking_care
        selected_assistance_expert.update status: :quo
      end

      it 'updates the taken_care_of_at to nil' do
        expect(selected_assistance_expert.taken_care_of_at).to be_nil
      end

      it 'leaves the closed_at timestamp at nil' do
        expect(selected_assistance_expert.closed_at).to be_nil
      end
    end

    context 'status is quo and updating to taking_care' do
      before { selected_assistance_expert.update status: :taking_care }

      it 'updates the taken_care_of_at timestamp' do
        expect(selected_assistance_expert.taken_care_of_at).not_to be_nil
        expect(selected_assistance_expert.taken_care_of_at.to_date).to eq Date.today
      end

      it 'leaves the closed_at timestamp at nil' do
        expect(selected_assistance_expert.closed_at).to be_nil
      end
    end

    context 'status is quo and going back to done' do
      before { selected_assistance_expert.update status: :done }

      it 'updates the taken_care_of_at timestamp' do
        expect(selected_assistance_expert.taken_care_of_at).not_to be_nil
        expect(selected_assistance_expert.taken_care_of_at.to_date).to eq Date.today
      end

      it 'updates the closed_at timestamp' do
        expect(selected_assistance_expert.closed_at).not_to be_nil
        expect(selected_assistance_expert.closed_at.to_date).to eq Date.today
      end
    end

    context 'status is done and going back to taking_care' do
      before do
        selected_assistance_expert.update status: :done
        selected_assistance_expert.update status: :taking_care
      end

      it 'keeps the taken_care_of_at timestamp' do
        expect(selected_assistance_expert.taken_care_of_at).not_to be_nil
      end

      it 'updates the closed_at timestamp to nil' do
        expect(selected_assistance_expert.closed_at).to be_nil
      end
    end
  end

  describe 'assistance expert and territory user cannot both be set' do
    subject(:selected_assistance_expert) { build :selected_assistance_expert }

    let(:assistance_expert) { create :assistance_expert }
    let(:territory_user) { create :territory_user }

    context 'assistance expert and territory user cannot both be set' do
      before { selected_assistance_expert.assistance_expert = assistance_expert }

      it { is_expected.to be_valid }
    end

    context 'assistance expert and territory user cannot both be set' do
      before { selected_assistance_expert.territory_user = territory_user }

      it { is_expected.to be_valid }
    end

    context 'assistance expert and territory user cannot both be set' do
      before do
        selected_assistance_expert.assign_attributes assistance_expert: assistance_expert,
                                                     territory_user: territory_user
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe 'defaults' do
    let(:selected_assistance_expert) { create :selected_assistance_expert, :with_assistance_expert }

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
        create :selected_assistance_expert, :with_assistance_expert
      end

      it { is_expected.to eq [selected_assistance_expert] }
    end

    describe 'of_territory_user' do
      subject { SelectedAssistanceExpert.of_territory_user territory_user }

      let(:territory_user) { create :territory_user }
      let(:selected_assistance_expert) do
        create :selected_assistance_expert, territory_user: territory_user
      end

      before do
        create :territory_user
        create :selected_assistance_expert, :with_territory_user
      end

      it { is_expected.to eq [selected_assistance_expert] }
    end

    describe 'of_diagnoses' do
      subject { SelectedAssistanceExpert.of_diagnoses [diagnosis] }

      let(:diagnosis) { create :diagnosis }
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }
      let(:selected_assistance_expert) do
        create :selected_assistance_expert, :with_assistance_expert, diagnosed_need: diagnosed_need
      end

      before do
        create :diagnosed_need, diagnosis: diagnosis
        create :selected_assistance_expert, :with_assistance_expert
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

    describe 'updated_more_than_five_days_ago' do
      subject { SelectedAssistanceExpert.updated_more_than_five_days_ago }

      let!(:selected_ae_updated_two_weeks_ago) { create :selected_assistance_expert, updated_at: 2.weeks.ago }

      before { create :selected_assistance_expert, updated_at: 4.days.ago }

      it { is_expected.to match_array [selected_ae_updated_two_weeks_ago] }
    end

    describe 'needing_taking_care_update' do
      subject { SelectedAssistanceExpert.needing_taking_care_update }

      let!(:selected_ae_needing_update) do
        create :selected_assistance_expert, status: :taking_care
      end

      before do
        selected_ae_needing_update.update updated_at: 2.weeks.ago
        create :selected_assistance_expert, status: :taking_care, updated_at: 4.days.ago
        create :selected_assistance_expert, status: :quo, updated_at: 2.weeks.ago
        create :selected_assistance_expert, status: :done, updated_at: 2.weeks.ago
      end

      it { is_expected.to match_array [selected_ae_needing_update] }
    end

    describe 'with_no_one_in_charge' do
      subject { SelectedAssistanceExpert.with_no_one_in_charge }

      let(:abandoned_diagnosed_need) { create :diagnosed_need }
      let(:answered_diagnosed_need) { create :diagnosed_need }
      let(:other_answered_diagnosed_need) { create :diagnosed_need }

      let(:selected_aes_with_no_one_in_charge) do
        create_list :selected_assistance_expert,
                    2,
                    status: :quo,
                    diagnosed_need: abandoned_diagnosed_need,
                    updated_at: 6.days.ago
      end

      before do
        create :selected_assistance_expert,
               status: :quo,
               diagnosed_need: answered_diagnosed_need,
               updated_at: 6.days.ago

        create :selected_assistance_expert,
               status: :taking_care,
               diagnosed_need: answered_diagnosed_need,
               updated_at: 6.days.ago

        create :selected_assistance_expert,
               status: :done,
               diagnosed_need: other_answered_diagnosed_need,
               updated_at: 6.days.ago

        create :selected_assistance_expert,
               status: :not_for_me,
               diagnosed_need: other_answered_diagnosed_need,
               updated_at: 6.days.ago
      end

      it { is_expected.to match_array selected_aes_with_no_one_in_charge }
    end
  end
end
# rubocop:enable Metrics/BlockLength
