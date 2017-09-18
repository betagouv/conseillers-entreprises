# frozen_string_literal: true

require 'rails_helper'

describe AdminMailersService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_statistics_email' do
    subject(:send_statistics_email) { described_class.send_statistics_email }

    let!(:not_admin_user) { create :user, is_admin: false }

    before do
      allow(AdminMailer).to receive(:delay) { AdminMailer }
      allow(AdminMailer).to receive(:weekly_statistics).and_call_original
    end

    describe 'email method parameters' do
      context 'no data' do
        let(:expected_information_hash) do
          {
            signed_up_users: { count: 1, items: [not_admin_user] },
            created_diagnoses: { count: 0, items: [] },
            updated_diagnoses: { count: 0, items: [] },
            completed_diagnoses: { count: 0, items: [] },
            contacted_experts_count: 0
          }
        end

        it do
          send_statistics_email

          expect(AdminMailer).to have_received(:weekly_statistics).with(expected_information_hash)
        end
      end

      context 'some data' do
        let(:visit) { create :visit, advisor: not_admin_user }

        let(:created_diagnoses) { create_list :diagnosis, 1, step: 1, visit: visit }
        let(:completed_diagnoses) { create_list :diagnosis, 2, step: 5, visit: visit }
        let(:diagnosed_need) { create :diagnosed_need, diagnosis: completed_diagnoses.first }
        let(:updated_diagnoses) do
          create_list :diagnosis, 1, step: 4, visit: visit, created_at: 2.weeks.ago, updated_at: 1.hour.ago
        end

        let!(:expected_information_hash) do
          {
            signed_up_users: { count: 1, items: [not_admin_user] },
            created_diagnoses: { count: 1, items: created_diagnoses },
            updated_diagnoses: { count: 1, items: updated_diagnoses },
            completed_diagnoses: { count: 2, items: completed_diagnoses },
            contacted_experts_count: 3
          }
        end

        before do
          create :diagnosis, step: 1, visit: visit, created_at: 2.weeks.ago, updated_at: 2.weeks.ago
          create_list :selected_assistance_expert, 3, diagnosed_need: diagnosed_need
        end

        it do
          send_statistics_email

          expect(AdminMailer).to have_received(:weekly_statistics).with(expected_information_hash)
        end
      end
    end
  end
end
