# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosedNeed, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :diagnosis
      is_expected.to belong_to :question
      is_expected.to have_many :selected_assistance_experts
      is_expected.to validate_presence_of :diagnosis
    end
  end

  describe 'scopes' do
    describe 'of_diagnosis' do
      subject { DiagnosedNeed.of_diagnosis diagnosis }

      let(:diagnosis) { create :diagnosis }
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

      it { is_expected.to eq [diagnosed_need] }
    end

    describe 'of_question' do
      subject { DiagnosedNeed.of_question question }

      let(:question) { create :question }
      let(:diagnosed_need) { create :diagnosed_need, question: question }

      it { is_expected.to eq [diagnosed_need] }
    end

    describe 'of_expert' do
      subject { DiagnosedNeed.of_expert expert }

      let(:expert) { create :expert }
      let(:assistance_expert) { create :assistance_expert, expert: expert }
      let(:diagnosed_need) { create :diagnosed_need }

      before do
        create :selected_assistance_expert, assistance_expert: assistance_expert, diagnosed_need: diagnosed_need
        create :assistance_expert
        create :selected_assistance_expert
      end

      it { is_expected.to eq [diagnosed_need] }
    end

    describe 'of_territory_user' do
      subject { DiagnosedNeed.of_territory_user territory_user }

      let(:territory_user) { create :territory_user }
      let(:diagnosed_need) { create :diagnosed_need }

      before do
        create :selected_assistance_expert,
               territory_user: territory_user,
               diagnosed_need: diagnosed_need
        create :territory_user
        create :selected_assistance_expert
      end

      it { is_expected.to eq [diagnosed_need] }
    end

    describe 'with_at_least_one_expert_done' do
      subject { DiagnosedNeed.with_at_least_one_expert_done }

      let(:diagnosed_need) { create :diagnosed_need }

      before { create :diagnosed_need }

      context 'no expert done' do
        before do
          create :selected_assistance_expert, :with_assistance_expert, diagnosed_need: diagnosed_need, status: :quo
        end

        it { is_expected.to eq [] }
      end

      context 'two experts done for the same need' do
        before do
          create :selected_assistance_expert, :with_assistance_expert, diagnosed_need: diagnosed_need, status: :done
          create :selected_assistance_expert, :with_assistance_expert, diagnosed_need: diagnosed_need, status: :done
        end

        it { is_expected.to eq [diagnosed_need] }
      end
    end
  end
end
