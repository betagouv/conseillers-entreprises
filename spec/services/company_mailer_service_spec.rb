# frozen_string_literal: true

require 'rails_helper'
describe CompanyMailerService do
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
      described_class.send_retention_emails
      p need_2.with_status_done
      p need_2.diagnosis
      p need_2.maches
      p need_2.errors unless need_2.valid?
      p need_2.diagnosis.errors unless need_2.diagnosis.valid?
      p Need.joins(:diagnosis)
      p Need.joins(:diagnosis).where(diagnoses: { retention_email_sent: false })
      p Need.joins(:diagnosis).where(diagnoses: { retention_email_sent: false }, created_at: (Time.zone.now - 5.months - 2.days)..(Time.zone.now - 5.months))
      p Need.joins(:diagnosis).where(diagnoses: { retention_email_sent: false }, created_at: (Time.zone.now - 5.months - 2.days)..(Time.zone.now - 5.months)).with_status_done
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

    xit 'enqueues 3 mailer job' do
      expect(ActionMailer::Base.deliveries.count).to eq 3
    end

    xit 'updates retention_email_sent' do
      expect(need_2.diagnosis.reload.retention_email_sent).to eq true
      expect(need_3.diagnosis.reload.retention_email_sent).to eq true
      expect(need_4.diagnosis.reload.retention_email_sent).to eq true
    end
  end
end
