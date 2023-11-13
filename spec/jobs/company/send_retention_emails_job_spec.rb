require 'rails_helper'
RSpec.describe Company::SendRetentionEmailsJob do
  describe 'enqueue a job' do
    it { assert_enqueued_jobs(1) { described_class.perform_later } }
  end

  describe 'send_retention_emails' do
    before do
      need_1.matches.first.update(status: :done)
      need_2.matches.first.update(status: :done)
      need_3.matches.first.update(status: :done_not_reachable)
      need_4.matches.first.update(status: :done_no_help)
      need_5.matches.first.update(status: :not_for_me)
      need_6.matches.first.update(status: :taking_care)
      need_7.matches.first.update(status: :quo)
      need_8.matches.first.update(status: :done)
      need_9.matches.first.update(status: :done)
      described_class.perform_now
    end

    let(:two_months_ago) { Time.now - 2.months }
    let(:five_months_ago) { Time.now - 5.months }
    let(:seven_months_ago) { Time.now - 7.months }
    # Analyse de moins de 5 mois KO
    let!(:need_1) { create :need_with_matches, created_at: two_months_ago }
    # Analyse de plus de 5 mois et moins de 6 mois clôturé avec aide proposée OK
    let!(:need_2) { create :need_with_matches, created_at: five_months_ago }
    # Analyse de plus de 5 mois et moins de 6 mois clôturé avec injoignable OK
    let!(:need_3) { create :need_with_matches, created_at: five_months_ago }
    # Analyse de plus de 5 mois et moins de 6 mois clôturé avec pas d’aide disponible OK
    let!(:need_4) { create :need_with_matches, created_at: five_months_ago }
    # Analyse de plus de 5 mois et moins de 6 mois clôturé avec pas pour mois KO
    let!(:need_5) { create :need_with_matches, created_at: five_months_ago }
    # Analyse de plus de 5 mois et moins de 6 mois pris en charge KO
    let!(:need_6) { create :need_with_matches, created_at: five_months_ago }
    # Analyse de plus de 5 mois et moins de 6 mois en attente KO
    let!(:need_7) { create :need_with_matches, created_at: five_months_ago }
    # Analyse de plus de 5 mois et moins de 6 mois et avec un email deja envoyé KO
    let!(:diagnosis_8) { create :diagnosis_completed, created_at: five_months_ago, retention_email_sent: true }
    let!(:need_8) { create :need_with_matches, created_at: five_months_ago, diagnosis: diagnosis_8 }
    # Analyse de plus de 6 mois KO
    let!(:need_9) { create :need_with_matches, created_at: seven_months_ago }

    it 'enqueues 3 mailer job' do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
      expect(enqueued_jobs.count).to eq(3)
    end

    it 'updates retention_email_sent' do
      expect(need_1.diagnosis.reload.retention_email_sent).to be false
      expect(need_2.diagnosis.reload.retention_email_sent).to be true
      expect(need_3.diagnosis.reload.retention_email_sent).to be true
      expect(need_4.diagnosis.reload.retention_email_sent).to be true
      expect(need_5.diagnosis.reload.retention_email_sent).to be false
      expect(need_6.diagnosis.reload.retention_email_sent).to be false
      expect(need_7.diagnosis.reload.retention_email_sent).to be false
      expect(need_8.diagnosis.reload.retention_email_sent).to be true
      expect(need_9.diagnosis.reload.retention_email_sent).to be false
    end
  end
end
