# frozen_string_literal: true

require 'rails_helper'

describe UserDailyChangeUpdateMailerService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_daily_change_updates' do
    subject(:send_daily_change) { described_class.send_daily_change_updates }

    before do
      allow(UserMailer).to receive(:delay).and_return(UserMailer)
      allow(UserMailer).to receive(:daily_change_update)
    end

    context 'one selected assistance modified during the last 24h' do
      let(:match1) { create :match }
      let(:match2) { create :match }
      let(:expected_array) do
        [
          {
            expert_name: match2.expert_full_name,
            expert_institution: match2.expert_institution_name,
            question_title: match2.diagnosed_need.question_label,
            company_name: match2.diagnosed_need.diagnosis.visit.facility.company.name_short,
            start_date: match2.created_at.to_date,
            old_status: 'quo',
            current_status: 'done'
          }
        ]
      end

      before do
        match1.update status: 'done'
        match1.update updated_at: 2.days.ago
        Audited::Audit.last.update created_at: 2.days.ago

        match2.update status: 'done'

        send_daily_change
      end

      it 'sends only one email' do
        user = match2.diagnosed_need.diagnosis.visit.advisor
        expect(UserMailer).to have_received(:daily_change_update).once.with(user, expected_array)
      end
    end

    context 'two selected assistances for the same user modified during the last 24h' do
      let(:visit) { create :visit }
      let(:diagnosis) { create :diagnosis, visit: visit }
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }
      let(:match1) { create :match }
      let(:match2) { create :match, diagnosed_need: diagnosed_need }
      let(:match3) { create :match, diagnosed_need: diagnosed_need }
      let(:expected_array) do
        [
          {
            expert_name: match2.expert_full_name,
            expert_institution: match2.expert_institution_name,
            question_title: match2.diagnosed_need.question_label,
            company_name: match2.diagnosed_need.diagnosis.visit.facility.company.name_short,
            start_date: match2.created_at.to_date,
            old_status: 'quo',
            current_status: 'done'
          },
          {
            expert_name: match3.expert_full_name,
            expert_institution: match3.expert_institution_name,
            question_title: match2.diagnosed_need.question_label,
            company_name: match2.diagnosed_need.diagnosis.visit.facility.company.name_short,
            start_date: match3.created_at.to_date,
            old_status: 'quo',
            current_status: 'done'
          }
        ]
      end

      before do
        match1.update status: 'done'
        match1.update updated_at: 2.days.ago
        Audited::Audit.last.update created_at: 2.days.ago

        match2.update status: 'done'
        match3.update status: 'done'

        send_daily_change
      end

      it 'sends only one email' do
        user = match2.diagnosed_need.diagnosis.visit.advisor
        expect(UserMailer).to have_received(:daily_change_update).once.with(user, expected_array)
      end
    end

    context 'one selected assistance modified during the last 24h but no status update' do
      let(:match) { create :match }

      before do
        match.update status: 'done'
        match.update updated_at: 2.days.ago
        Audited::Audit.last.update created_at: 2.days.ago
        match.update status: 'quo'
        match.update status: 'done'

        send_daily_change
      end

      it 'sends no email' do
        expect(UserMailer).not_to have_received(:daily_change_update)
      end
    end
  end
end
