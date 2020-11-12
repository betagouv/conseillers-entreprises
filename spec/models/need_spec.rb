# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Need, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :diagnosis
      is_expected.to belong_to :subject
      is_expected.to have_many :matches
      is_expected.to validate_presence_of :diagnosis
    end
  end

  describe 'subject uniqueness in the scope of a diagnosis' do
    subject { build :need, diagnosis: diagnosis, subject: subject1 }

    let(:diagnosis) { create :diagnosis }
    let(:subject1) { create :subject }

    context 'unique need for this subject' do
      it { is_expected.to be_valid }
    end

    context 'need for another subject' do
      before { create :need, diagnosis: diagnosis, subject: subject2 }

      let(:subject2) { create :subject }

      it { is_expected.to be_valid }
    end

    context 'need for the same subject' do
      before { create :need, diagnosis: diagnosis, subject: subject1 }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'status' do
    subject { need.status }

    let(:need) { create :need, matches: matches, diagnosis: diagnosis }

    let(:diagnosis) { create :diagnosis_completed }
    let(:matches) { [] }

    let(:quo_match) { create :match, status: :quo }
    let(:taking_care_match) { create :match, status: :taking_care }
    let(:done_match) { create :match, status: :done }
    let(:not_for_me_match) { create :match, status: :not_for_me }

    context 'diagnosis not complete' do
      let(:diagnosis) { create :diagnosis, step: :not_started }

      it { is_expected.to eq 'diagnosis_not_complete' }
    end

    context 'with no match' do
      let(:matches) { [] }

      it { is_expected.to eq 'diagnosis_not_complete' }
    end

    context 'with at least a match done' do
      let(:matches) { [quo_match, taking_care_match, not_for_me_match, done_match] }

      it { is_expected.to eq 'done' }
    end

    context 'with at least a match taking_care' do
      let(:matches) { [quo_match, taking_care_match, not_for_me_match] }

      it { is_expected.to eq 'taking_care' }
    end

    context 'with all matches not_for_me' do
      let(:matches) { [not_for_me_match, not_for_me_match] }

      it { is_expected.to eq 'not_for_me' }
    end

    context 'with matches still quo' do
      let(:matches) { [quo_match, quo_match, not_for_me_match] }

      it { is_expected.to eq 'quo' }
    end
  end

  describe 'scopes' do
    describe 'with_some_matches_in_status' do
      subject { described_class.with_some_matches_in_status(:done) }

      let(:need) { create :need }

      before { create :need }

      context 'with no match' do
        it { is_expected.to eq [] }
      end

      context 'with matches, not done' do
        before do
          create :match, need: need, status: :quo
        end

        it { is_expected.to eq [] }
      end

      context 'with matches, done' do
        before do
          create :match, need: need, status: :quo
          create :match, need: need, status: :done
        end

        it { is_expected.to eq [need] }
      end
    end

    describe 'with_matches_only_in_status' do
      subject { described_class.with_matches_only_in_status(:quo) }

      let(:need1) { create :need }
      let(:need2) { create :need }
      let(:need3) { create :need }

      context 'with no match' do
        it { is_expected.to eq [] }
      end

      context 'with various matches' do
        before do
          create_list :match, 2, status: :quo, need: need1
          create :match, status: :quo, need: need2
          create :match, status: :taking_care, need: need2
          create :match, status: :done, need: need3
          create :match, status: :not_for_me, need: need3
        end

        it { is_expected.to eq [need1] }
      end
    end

    describe 'ordered_for_interview' do
      subject { described_class.ordered_for_interview }

      context 'with subjects and themes' do
        let(:t1)    { create :theme, interview_sort_order: 1 }
        let(:t2)    { create :theme, interview_sort_order: 2 }
        let(:s1)    { create :subject, interview_sort_order: 1, theme: t1 }
        let(:s2)    { create :subject, interview_sort_order: 2, theme: t1 }
        let(:s3)    { create :subject, interview_sort_order: 1, theme: t2 }
        let(:s4)    { create :subject, interview_sort_order: 2, theme: t2 }
        let(:need1) { create  :need, subject: s1 }
        let(:need2) { create  :need, subject: s2 }
        let(:need3) { create  :need, subject: s3 }
        let(:need4) { create  :need, subject: s4 }

        it { is_expected.to eq [need1, need2, need3, need4] }
      end
    end

    describe 'active' do
      subject { described_class.active }

      let!(:need1) do
        create :need, matches: [
          create(:match, status: :quo),
          create(:match, status: :not_for_me),
        ]
      end
      let!(:need2) do
        create :need, matches: [
          create(:match, status: :taking_care),
          create(:match, status: :quo),
        ]
      end

      before do
        create :need, matches: [
          create(:match, status: :quo),
          create(:match, status: :done),
        ]
        create :need, matches: [
          create(:match, status: :not_for_me)
        ]
      end

      it { is_expected.to match_array [need1, need2] }
    end

    describe 'reminder_quo_not_taken' do
      let(:date1) { Time.zone.now.beginning_of_day }
      let(:date2) { date1 - 11.days }

      let(:need1) { travel_to(date1) { create :need_with_matches } }
      let(:need2) { travel_to(date2) { create :need_with_matches } }
      let(:need3) { travel_to(date2) { create :need_with_matches, archived_at: date2 } }
      let(:need4) { travel_to(date2) { create :need_with_matches } }
      let(:feedback1) { create :feedback, :for_need, feedbackable: need4 }

      before do
        need1
        need2
        need3
        feedback1
      end

      subject { described_class.reminder_quo_not_taken }

      it 'expect to have needs not updated without comment for more than 10 days' do
        is_expected.to eq [need2]
      end
    end

    describe 'reminder_in_progress' do
      let(:date1) { Time.zone.now.beginning_of_day }
      let(:date2) { date1 - 11.days }
      let(:need1) { travel_to(date1) { create :need_with_matches } }
      let(:need2) { travel_to(date2) { create :need_with_matches } }
      let(:need3) { travel_to(date2) { create :need_with_matches } }
      let!(:feedback1) { create :feedback, :for_need, feedbackable: need2 }

      before do
        need1
        feedback1
        need3
      end

      subject { described_class.reminder_in_progress }

      it 'expected to have needs quo with comments' do
        is_expected.to eq [need2]
      end
    end

    describe 'abandoned_without_taking_care' do
      let(:date1) { Time.zone.now.beginning_of_day }
      let(:date2) { date1 - 31.days }
      let(:recent_need) { travel_to(date1) { create :need_with_matches } }
      let(:need_quo) { travel_to(date2) { create :need_with_matches } }
      let(:need_recent_match) { travel_to(date2) { create :need, matches: [recent_match] } }
      let(:recent_match) { travel_to(date1) { create :match } }
      let(:need_done_no_help) { travel_to(date2) { create :need, matches: [create(:match, status: :done_no_help)] } }
      let(:need_done_not_reachable) { travel_to(date2) { create :need, matches: [create(:match, status: :done_not_reachable)] } }
      let(:need_need_not_for_me) { travel_to(date2) { create :need, matches: [create(:match, status: :not_for_me)] } }

      before do
        recent_need
        need_quo
        recent_match
        need_done_no_help
        need_done_not_reachable
        need_need_not_for_me
      end

      subject { described_class.abandoned_without_taking_care }

      it 'expect to have needs without taking care in 30 last days' do
        is_expected.to eq [need_quo, need_done_no_help, need_done_not_reachable, need_need_not_for_me]
      end
    end

    describe 'reminder' do
      let(:date1) { Time.zone.now.beginning_of_day }
      let(:date2) { date1 - 11.days }
      let(:date3) { date1 - 31.days }
      let(:new_need) { travel_to(date1) { create :need_with_matches } }
      let(:mid_need) { travel_to(date2) { create :need_with_matches } }
      let(:old_need) { travel_to(date3) { create :need_with_matches } }

      before do
        new_need
        mid_need
        old_need
      end

      subject { described_class.reminder }

      it 'expect to have needs between 10 and 30 days' do
        is_expected.to eq [mid_need]
      end
    end

    describe 'by_status_no_help' do
      let(:match_taking_care) { create(:match, status: :taking_care) }
      let(:match_done) { create(:match, status: :done) }
      let(:match_quo) { create(:match, status: :quo) }
      let(:match_done_no_help) { create(:match, status: :done_no_help) }
      let(:match_done_not_reachable) { create(:match, status: :done_not_reachable) }
      let(:match_not_for_me) { create(:match, status: :not_for_me) }

      before do
        match_taking_care
        match_done
        match_quo
        match_done_no_help
        match_done_not_reachable
        match_not_for_me
      end

      subject { described_class.no_help_provided.order(:id) }

      it { is_expected.to eq [match_quo.need, match_done_no_help.need, match_done_not_reachable.need, match_not_for_me.need] }
    end
  end

  describe 'abandoned' do
    let(:need) { create :need_with_matches }
    let(:date1) { Time.zone.now - 2.months }
    let(:old_need) { travel_to(date1) { create :need_with_matches } }

    it do
      expect(need).not_to be_abandoned
      expect(old_need).to be_abandoned
      expect(described_class.abandoned).to match_array([old_need])

      travel_to(2.months.from_now) do
        expect(need).to be_abandoned
        expect(old_need).to be_abandoned
        expect(described_class.abandoned).to match_array([need, old_need])
      end
    end
  end

  describe 'touch diagnosis' do
    let(:date1) { Time.zone.now.beginning_of_day }
    let(:date2) { date1 + 1.minute }
    let(:date3) { date1 + 2.minutes }

    let(:diagnosis) { travel_to(date1) { create :diagnosis } }

    before { diagnosis }

    subject { diagnosis.reload.updated_at }

    context 'when a need is added to a diagnosis' do
      let(:need) { travel_to(date3) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { diagnosis.needs = [need] }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a need is removed from a diagnosis' do
      let(:need) { travel_to(date1) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { need.destroy }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a need is updated' do
      let(:need) { travel_to(date1) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { need.update(content: 'New content') }
      end

      it { is_expected.to eq date3 }
    end
  end

  describe 'update_last_activity_at' do
    let(:date1) { Time.zone.now.beginning_of_day }
    let(:date2) { date1 + 1.minute }
    let(:date3) { date1 + 2.minutes }

    let(:need) { travel_to(date1) { create :need } }
    let(:match) { travel_to(date2) { create :match, need: need } }

    before { need.reload; match }

    subject { need.reload.last_activity_at }

    context 'when a match is updated' do
      before { travel_to(date3) { match.update(status: :done) } }

      it { is_expected.to eq date3 }
    end

    context 'when a feedback is added to a match' do
      let(:feedback) { travel_to(date3) { create :feedback, feedbackable: need } }

      before { need.reload; feedback }

      it { is_expected.to eq date2 }
    end
  end

  describe 'update_status' do
    let(:need) { create :need_with_matches }

    before { need.matches.first.update(status: :taking_care) }

    subject { need.reload.status }

    it { is_expected.to eq 'taking_care' }
  end
end
