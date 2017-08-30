# frozen_string_literal: true

require 'rails_helper'

describe AdminMailersService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_statistics_email' do
    subject(:send_statistics_email) { described_class.send_statistics_email }

    let!(:not_admin_user) { create :user, is_admin: false }

    describe 'email method parameters' do
      context 'no data' do
        before do
          allow(AdminMailer).to receive(:delay) { AdminMailer }
          allow(AdminMailer).to receive(:weekly_statistics).and_call_original
          send_statistics_email
        end

        it do
          information_hash = {
            signed_up_users: { count: 1, items: [not_admin_user] },
            visits: [],
            diagnoses: [],
            mailto_logs: []
          }
          expect(AdminMailer).to have_received(:weekly_statistics).with(information_hash)
        end
      end

      context 'some data' do
        let(:visit) { create :visit, advisor: not_admin_user }

        before do
          create :diagnosis, visit: visit
          create :mailto_log, created_at: 5.days.ago, visit: visit
          allow(AdminMailer).to receive(:delay) { AdminMailer }
          allow(AdminMailer).to receive(:weekly_statistics).and_call_original
          send_statistics_email
        end

        it do
          information_hash = {
            signed_up_users: { count: 1, items: [not_admin_user] },
            visits: [{ user: not_admin_user, visits_count: 1 }],
            diagnoses: [{ visit: visit, diagnoses_count: 1 }],
            mailto_logs: [{ visit: visit, logs_count: 1 }]
          }
          expect(AdminMailer).to have_received(:weekly_statistics).with(information_hash)
        end
      end
    end
  end
end
