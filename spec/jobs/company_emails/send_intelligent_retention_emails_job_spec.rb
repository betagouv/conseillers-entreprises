require 'rails_helper'
RSpec.describe CompanyEmails::SendIntelligentRetentionEmailsJob do
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

    let!(:match_ok) do # Un besoin cloturé par une aide, dans le sujet et dans les delais OK
      create :match, status: :done, created_at: 2.months.ago, closed_at: 2.months.ago,
             need: build(:need, status: :done, subject: initial_subject)
    end
    let!(:match_already_relaunch) do # Un besoin cloturé par une aide, dans le sujet et dans les delais, mais deja relancé KO
      create :match, status: :done, created_at: 2.months.ago, closed_at: 2.months.ago,
             need: build(:need, status: :done, subject: initial_subject, retention_sent_at: Time.zone.now)
    end
    let!(:match_wrong_delays) do # Un besoin cloturé par une aide, dans le sujet mais pas dans les delais KO
      create :match, status: :done,
             need: build(:need, status: :done, subject: initial_subject)
    end
    let!(:match_wrong_subject) do # Un besoin cloturé par une aide, pas dans le sujet mais dans les delais KO
      create :match, status: :done, created_at: 2.months.ago, closed_at: 2.months.ago,
             need: build(:need, status: :done, created_at: 2.months.ago)
    end
    let!(:match_without_help) do # Un besoin cloturé sans aide, dans le sujet et dans les delais
      create :match, status: :not_for_me, created_at: 2.months.ago, closed_at: 2.months.ago,
             need: build(:need, status: :not_for_me, subject: initial_subject, created_at: 2.months.ago)
    end
    let!(:match_all_wrong) do # Un besoin cloturé sans aide pas, dans le sujet et pas dans les delais KO
      create :match, status: :not_for_me,
             need: build(:need, status: :not_for_me)
    end

    before do
      Need.all.map(&:update_status)
      described_class.perform_now
    end

    it do
      expect(match_ok.need.reload.retention_sent_at).not_to be_nil # todo: finish this
      expect(match_already_relaunch.need.reload.retention_sent_at).not_to be_nil
      expect(match_wrong_delays.need.reload.retention_sent_at).to be_nil
      expect(match_wrong_subject.need.reload.retention_sent_at).to be_nil
      expect(match_without_help.need.reload.retention_sent_at).to be_nil
      expect(match_all_wrong.need.reload.retention_sent_at).to be_nil
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
      expect(enqueued_jobs.count).to eq 1
    end
  end
end
