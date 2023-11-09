require 'rails_helper'
RSpec.describe Company::SendIntelligentRetentionEmailsJob, type: :job do
  describe 'enqueue a job' do
    it { assert_enqueued_jobs(1) { described_class.perform_later } }
  end

  describe 'send_emails' do
    let!(:initial_subject) { create :subject }
    let!(:first_subject) { create :subject }
    let!(:second_subject) { create :subject }
    let!(:accueil) { create :landing, slug: 'accueil', landing_themes: [landing_theme] }
    let!(:landing_theme) { create :landing_theme, landing_subjects: [create(:landing_subject, subject: initial_subject), create(:landing_subject, subject: first_subject), create(:landing_subject, subject: second_subject)] }
    let!(:email_retention) { create :email_retention, subject: initial_subject, waiting_time: 1, first_subject: first_subject, second_subject: second_subject }
    # Un besoin cloturé par une aide, dans le sujet et dans les delais OK
    let!(:need_ok) { create :need, status: :done, subject: initial_subject, matches: [need_ok_match] }
    let!(:need_ok_match) { create :match, status: :done, created_at: 2.months.ago, closed_at: 2.months.ago }
    # Un besoin cloturé par une aide, dans le sujet et dans les delais, mais deja relancé OK
    let!(:need_already_relaunch) { create :need, status: :done, subject: initial_subject, retention_sent_at: Time.zone.now, matches: [need_already_relaunch_match] }
    let!(:need_already_relaunch_match) { create :match, status: :done, created_at: 2.months.ago, closed_at: 2.months.ago }
    # Un besoin cloturé par une aide, dans le sujet mais pas dans les delais KO
    let!(:need_wrong_delays) { create :need, status: :done, subject: initial_subject, matches: [need_wrong_delays_match] }
    let!(:need_wrong_delays_match) { create :match, status: :done }
    # Un besoin cloturé par une aide, pas dans le sujet mais dans les delais KO
    let!(:need_wrong_subject) { create :need, status: :done, created_at: 2.months.ago, matches: [need_wrong_subject_match] }
    let!(:need_wrong_subject_match) { create :match, status: :done, created_at: 2.months.ago, closed_at: 2.months.ago }
    # Un besoin cloturé sans aide, dans le sujet et dans les delais
    let!(:need_without_help) { create :need, status: :not_for_me, subject: initial_subject, created_at: 2.months.ago, matches: [need_without_help_match] }
    let!(:need_without_help_match) { create :match, status: :not_for_me, created_at: 2.months.ago, closed_at: 2.months.ago }
    # Un besoin cloturé sans aide pas, dans le sujet et pas dans les delais OK
    let!(:need_all_wrong) { create :need, status: :not_for_me, matches: [need_all_wrong_match] }
    let!(:need_all_wrong_match) { create :match, status: :not_for_me }

    before do
      Need.all.map(&:update_status)
      described_class.perform_now
    end

    describe 'send emails and fill retention_sent_at' do
      it do
        expect(need_ok.reload.retention_sent_at).not_to be_nil
        expect(need_already_relaunch.reload.retention_sent_at).not_to be_nil
        expect(need_wrong_delays.reload.retention_sent_at).to be_nil
        expect(need_wrong_subject.reload.retention_sent_at).to be_nil
        expect(need_without_help.reload.retention_sent_at).to be_nil
        expect(need_all_wrong.reload.retention_sent_at).to be_nil
        assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
      end
    end
  end
end
