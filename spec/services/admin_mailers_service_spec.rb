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
            completed_diagnoses: { count: 0, items: [] },
            contacted_experts_count: 0
          }
          expect(AdminMailer).to have_received(:weekly_statistics).with(information_hash)
        end
      end

      context 'some data' do
        let(:visit) { create :visit, advisor: not_admin_user }
        let(:completed_diagnoses) { create_list :diagnosis, 2, step: 5, visit: visit }
        let(:diagnosed_need) { create :diagnosed_need, diagnosis: completed_diagnoses.first }

        before do
          create :diagnosis, step: 1, visit: visit
          create_list :selected_assistance_expert, 3, diagnosed_need: diagnosed_need

          allow(AdminMailer).to receive(:delay) { AdminMailer }
          allow(AdminMailer).to receive(:weekly_statistics).and_call_original
          send_statistics_email
        end

        it do
          information_hash = {
            signed_up_users: { count: 1, items: [not_admin_user] },
            completed_diagnoses: { count: 2, items: completed_diagnoses },
            contacted_experts_count: 3
          }
          expect(AdminMailer).to have_received(:weekly_statistics).with(information_hash)
        end
      end
    end
  end
end
