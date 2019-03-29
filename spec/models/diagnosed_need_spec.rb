# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosedNeed, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :diagnosis
      is_expected.to belong_to :subject
      is_expected.to have_many :matches
      is_expected.to validate_presence_of :diagnosis
    end
  end

  describe 'subject uniqueness in the scope of a diagnosis' do
    subject { build :diagnosed_need, diagnosis: diagnosis, subject: subject1 }

    let(:diagnosis) { create :diagnosis }
    let(:subject1) { create :subject }

    context 'unique diagnosed_need for this subject' do
      it { is_expected.to be_valid }
    end

    context 'diagnosed_need for another subject' do
      before { create :diagnosed_need, diagnosis: diagnosis, subject: subject2 }

      let(:subject2) { create :subject }

      it { is_expected.to be_valid }
    end

    context 'diagnosed_need for the same subject' do
      before { create :diagnosed_need, diagnosis: diagnosis, subject: subject1 }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'status' do
    subject { diagnosed_need.status }

    let(:diagnosed_need) { create :diagnosed_need, matches: matches, diagnosis: diagnosis }

    let(:diagnosis) { create :diagnosis, step: 5 }
    let(:matches) { [] }

    let(:quo_match) { build :match, status: :quo }
    let(:taking_care_match) { build :match, status: :taking_care }
    let(:done_match) { build :match, status: :done }
    let(:not_for_me_match) { build :match, status: :not_for_me }

    context 'diagnosis not complete' do
      let(:diagnosis) { create :diagnosis, step: 1 }

      it { is_expected.to eq :diagnosis_not_complete }
    end

    context 'with no match' do
      let(:matches) { [] }

      it { is_expected.to eq :sent_to_no_one }
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
          create :match, :with_expert_skill, diagnosed_need: diagnosed_need, status: :quo
        end

        it { is_expected.to eq [] }
      end

      context 'with matches, done' do
        before do
          create :match, :with_expert_skill, diagnosed_need: diagnosed_need, status: :quo
          create :match, :with_expert_skill, diagnosed_need: diagnosed_need, status: :done
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

    describe 'ordered_for_interview' do
      subject { DiagnosedNeed.ordered_for_interview }

      context 'with subjects and themes' do
        let(:t1)    { create :theme, interview_sort_order: 1 }
        let(:t2)    { create :theme, interview_sort_order: 2 }
        let(:s1)    { create :subject, interview_sort_order: 1, theme: t1 }
        let(:s2)    { create :subject, interview_sort_order: 2, theme: t1 }
        let(:s3)    { create :subject, interview_sort_order: 1, theme: t2 }
        let(:s4)    { create :subject, interview_sort_order: 2, theme: t2 }
        let(:need1) { create  :diagnosed_need, subject: s1 }
        let(:need2) { create  :diagnosed_need, subject: s2 }
        let(:need3) { create  :diagnosed_need, subject: s3 }
        let(:need4) { create  :diagnosed_need, subject: s4 }

        it { is_expected.to eq [need1, need2, need3, need4] }
      end
    end
  end

  describe 'contacted_persons' do
    subject { diagnosed_need.contacted_persons }

    let(:diagnosed_need) { create :diagnosed_need, matches: matches }
    let(:relay) { build :relay }
    let(:expert) { build :expert }
    let(:relay_match) { build :match, relay: relay }
    let(:expert_skill) { build :expert_skill, expert: expert }
    let(:expert_match) { build :match, expert_skill: expert_skill }
    let(:expert_match2) { build :match, expert_skill: expert_skill }

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

  describe 'last_activity_at' do
    subject { diagnosed_need.last_activity_at.beginning_of_day }

    let(:diagnosed_need) { create :diagnosed_need }
    let(:match) { build :match, diagnosed_need: diagnosed_need }
    let(:feedback) { build :feedback, match: match }

    let(:date1) { Time.zone.now.beginning_of_day }
    let(:date2) { date1 + 5.days }
    let(:date3) { date1 + 10.days }

    context 'with no match activity' do
      it { is_expected.to eq date1 }
    end

    context 'with recent match activity' do
      before do
        Timecop.travel(date2) do
          match.save
        end
      end

      it { is_expected.to eq date2 }
    end

    context 'with recent feedback' do
      before do
        Timecop.travel(date3) do
          feedback.save
        end
      end

      it { is_expected.to eq date3 }
    end
  end
end
