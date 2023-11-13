require 'rails_helper'
RSpec.describe Company::NotYetTakenCareJob do
  let(:some_days_ago) { described_class::WAITING_TIME.ago }
  # solicitation sans diagnosis KO
  let!(:solicitation_without_diagnosis) { create :solicitation, status: :processed, created_at: some_days_ago }
  # solicitation avec need done KO
  let(:solicitation_done) { create :solicitation, status: :processed, created_at: some_days_ago }
  let(:diagnosis_done) { create :diagnosis, solicitation: solicitation_done }
  let(:need_done) { create :need, diagnosis: diagnosis_done }
  let!(:matches_done) { create :match, status: :done, need: need_done }
  # solicitation avec need quo dans les temps OK
  let(:solicitation_quo_in_time) { create :solicitation, status: :processed, created_at: some_days_ago }
  let(:diagnosis_quo_in_time) { create :diagnosis, solicitation: solicitation_quo_in_time }
  let(:need_quo_in_time) { create :need, diagnosis: diagnosis_quo_in_time }
  let!(:matches_quo_in_time) { create :match, status: :quo, need: need_quo_in_time }
  # solicitation avec need quo pas dans les temps KO
  let(:solicitation_quo_not_in_time) { create :solicitation, status: :processed }
  let(:diagnosis_quo_not_in_time) { create :diagnosis, solicitation: solicitation_quo_not_in_time }
  let(:need_quo_not_in_time) { create :need, diagnosis: diagnosis_quo_not_in_time }
  let!(:matches_quo_not_in_time) { create :match, status: :quo, need: need_quo_not_in_time }
  # solicitation avec need taking_care KO
  let(:solicitation_taking_care) { create :solicitation, status: :processed, created_at: some_days_ago }
  let(:diagnosis_taking_care) { create :diagnosis, solicitation: solicitation_taking_care }
  let(:need_taking_care) { create :need, diagnosis: diagnosis_taking_care }
  let!(:matches_taking_care) { create :match, status: :taking_care, need: need_taking_care }
  # solicitation avec need done_no_help KO
  let(:solicitation_done_no_help) { create :solicitation, status: :processed, created_at: some_days_ago }
  let(:diagnosis_done_no_help) { create :diagnosis, solicitation: solicitation_done_no_help }
  let(:need_done_no_help) { create :need, diagnosis: diagnosis_done_no_help }
  let!(:matches_done_no_help) { create :match, status: :done_no_help, need: need_done_no_help }
  # solicitation avec need done_not_reachable KO
  let(:solicitation_done_not_reachable) { create :solicitation, status: :processed, created_at: some_days_ago }
  let(:diagnosis_done_not_reachable) { create :diagnosis, solicitation: solicitation_done_not_reachable }
  let(:need_done_not_reachable) { create :need, diagnosis: diagnosis_done_not_reachable }
  let!(:matches_done_not_reachable) { create :match, status: :done_not_reachable, need: need_done_not_reachable }
  # solicitation avec need not_for_me KO
  let(:solicitation_not_for_me) { create :solicitation, status: :processed, created_at: some_days_ago }
  let(:diagnosis_not_for_me) { create :diagnosis, solicitation: solicitation_not_for_me }
  let(:need_not_for_me) { create :need, diagnosis: diagnosis_not_for_me }
  let!(:matches_not_for_me) { create :match, status: :not_for_me, need: need_not_for_me }

  describe 'perform_now' do
    before { described_class.perform_now }

    it { assert_enqueued_with(job: ActionMailer::MailDeliveryJob) }
  end

  describe 'enqueue a job' do
    it { assert_enqueued_jobs(1) { described_class.perform_later } }
  end

  describe 'retrieve_solicitations' do
    subject { described_class.new.send(:retrieve_solicitations) }

    it { is_expected.to contain_exactly(solicitation_quo_in_time) }
  end
end
