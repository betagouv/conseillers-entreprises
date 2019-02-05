# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosedNeed, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :diagnosis
      is_expected.to belong_to :question
      is_expected.to have_many :matches
      is_expected.to validate_presence_of :diagnosis
    end
  end

  describe 'question uniqueness in the scope of a diagnosis' do
    subject { build :diagnosed_need, diagnosis: diagnosis, question: question }

    let(:diagnosis) { create :diagnosis }
    let(:question) { create :question }

    context 'unique diagnosed_need for this question' do
      it { is_expected.to be_valid }
    end

    context 'diagnosed_need for another question' do
      before { create :diagnosed_need, diagnosis: diagnosis, question: question2 }

      let(:question2) { create :question }

      it { is_expected.to be_valid }
    end

    context 'diagnosed_need for the same question' do
      before { create :diagnosed_need, diagnosis: diagnosis, question: question }

      it { is_expected.not_to be_valid }
    end

    context 'several diagnosed_needs for a nil question' do
      before { create :diagnosed_need, diagnosis: diagnosis, question: nil }

      let(:question) { nil }

      it { is_expected.to be_valid }
    end
  end

  describe 'status_synthesis' do
    subject { diagnosed_need.status_synthesis }

    let(:diagnosed_need) { create :diagnosed_need, matches: matches }

    let(:quo_match) { build :match, status: :quo }
    let(:taking_care_match) { build :match, status: :taking_care }
    let(:done_match) { build :match, status: :done }
    let(:not_for_me_match) { build :match, status: :not_for_me }

    context 'with no match' do
      let(:matches) { [] }

      it { is_expected.to eq :quo }
    end

    context 'with at least a match done' do
      let(:matches) { [quo_match, taking_care_match, not_for_me_match, done_match] }

      it { is_expected.to eq :done }
    end

    context 'with at least a match taking_care' do
      let(:matches) { [quo_match, taking_care_match, not_for_me_match] }

      it { is_expected.to eq :taking_care }
    end

    context 'with all matches not_for_me' do
      let(:matches) { [not_for_me_match, not_for_me_match] }

      it { is_expected.to eq :not_for_me }
    end

    context 'with matches still quo' do
      let(:matches) { [quo_match, quo_match, not_for_me_match] }

      it { is_expected.to eq :quo }
    end
  end

  describe 'scopes' do
    describe 'with_some_matches_in_status' do
      subject { DiagnosedNeed.with_some_matches_in_status(:done) }

      let(:diagnosed_need) { create :diagnosed_need }

      before { create :diagnosed_need }

      context 'with no match' do
        it { is_expected.to eq [] }
      end

      context 'with matches, not done' do
        before do
          create :match, :with_assistance_expert, diagnosed_need: diagnosed_need, status: :quo
        end

        it { is_expected.to eq [] }
      end

      context 'with matches, done' do
        before do
          create :match, :with_assistance_expert, diagnosed_need: diagnosed_need, status: :quo
          create :match, :with_assistance_expert, diagnosed_need: diagnosed_need, status: :done
        end

        it { is_expected.to eq [diagnosed_need] }
      end
    end

    describe 'with_matches_only_in_status' do
      subject { DiagnosedNeed.with_matches_only_in_status(:quo) }

      let(:need1) { create :diagnosed_need }
      let(:need2) { create :diagnosed_need }
      let(:need3) { create :diagnosed_need }

      context 'with no match' do
        it { is_expected.to eq [] }
      end

      context 'with various matches' do
        before do
          create_list :match, 2, status: :quo, diagnosed_need: need1
          create :match, status: :quo, diagnosed_need: need2
          create :match, status: :taking_care, diagnosed_need: need2
          create :match, status: :done, diagnosed_need: need3
          create :match, status: :not_for_me, diagnosed_need: need3
        end

        it { is_expected.to eq [need1] }
      end
    end

    describe 'ordered_by_interview' do
      subject { DiagnosedNeed.ordered_by_interview }

      context 'with questions and categories' do
        let(:cat1)  { create :category, interview_sort_order: 1 }
        let(:cat2)  { create :category, interview_sort_order: 2 }
        let(:q1)    { create :question, interview_sort_order: 1, category: cat1 }
        let(:q2)    { create :question, interview_sort_order: 2, category: cat1 }
        let(:q3)    { create :question, interview_sort_order: 1, category: cat2 }
        let(:q4)    { create :question, interview_sort_order: 2, category: cat2 }
        let(:need1) { create  :diagnosed_need, question: q1 }
        let(:need2) { create  :diagnosed_need, question: q2 }
        let(:need3) { create  :diagnosed_need, question: q3 }
        let(:need4) { create  :diagnosed_need, question: q4 }

        it { is_expected.to eq [need1, need2, need3, need4] }
      end

      context 'with an orphan need' do
        let(:cat1)  { create :category, interview_sort_order: 1 }
        let(:q1)    { create :question, interview_sort_order: 1, category: cat1 }
        let(:need1) { create  :diagnosed_need, question: q1 }
        let(:need2) { create  :diagnosed_need, question: nil }

        it { is_expected.to eq [need1, need2] }
      end
    end
  end

  describe 'contacted_persons' do
    subject { diagnosed_need.contacted_persons }

    let(:diagnosed_need) { create :diagnosed_need, matches: matches }
    let(:relay) { build :relay }
    let(:expert) { build :expert }
    let(:relay_match) { build :match, relay: relay }
    let(:assistance_expert) { build :assistance_expert, expert: expert }
    let(:expert_match) { build :match, assistance_expert: assistance_expert }
    let(:expert_match2) { build :match, assistance_expert: assistance_expert }

    context 'No matches' do
      let(:matches) { [] }

      it { is_expected.to be_empty }
    end

    context 'Matches with both relays and experts' do
      let(:matches) { [expert_match, relay_match] }

      it { is_expected.to match_array [expert, relay.user] }
    end

    context 'Matches wit the same expert' do
      let(:matches) { [expert_match, expert_match2] }

      it { is_expected.to match_array [expert] }
    end
  end
end
