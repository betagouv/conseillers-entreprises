# frozen_string_literal: true

require 'rails_helper'

describe RelayService::MailerService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_relay_stats_emails' do
    subject(:send_relay_stats_emails) { described_class.send_relay_stats_emails }

    let(:not_admin_user) { create :user, is_admin: false }

    before do
      allow(RelayMailer).to receive(:delay).and_return(RelayMailer)
      allow(RelayMailer).to receive(:weekly_statistics).and_call_original
    end

    describe 'email method parameters' do
      let(:territories) { create_list :territory, 2 }
      let!(:territory1_user) { create :relay, territory: territories.first }

      let(:commune1) { create :commune, territories: [territories.first] }
      let(:facility1) { create :facility, commune: commune1 }

      let(:empty_information_hash) do
        {
          created_diagnoses: { count: 0, items: [] },
          updated_diagnoses: { count: 0, items: [] },
          completed_diagnoses: { count: 0, items: [] },
          matches_count: 0
        }
      end

      context 'no data' do
        before { send_relay_stats_emails }

        it 'sends one email' do
          expect(RelayMailer).to have_received(:weekly_statistics).once.with(
            territory1_user, empty_information_hash, an_instance_of(String)
          )
        end
      end

      context 'some data' do
        let!(:territory2_user1) { create :relay, territory: territories.last }
        let!(:territory2_user2) { create :relay, territory: territories.last }

        let(:commune2) { create :commune, territories: [territories.last] }
        let(:facility2) { create :facility, commune: commune2 }

        let(:created_diagnoses) { create_list :diagnosis, 1, step: 1, facility: facility1 }
        let(:completed_diagnoses) { create_list :diagnosis, 2, step: 5, facility: facility1 }
        let(:need) { create :need, diagnosis: completed_diagnoses.first }
        let(:updated_diagnoses) do
          create_list :diagnosis, 1, step: 4, facility: facility1, created_at: 2.weeks.ago, updated_at: 1.hour.ago
        end

        let!(:information_hash_with_data) do
          {
            created_diagnoses: { count: 1, items: created_diagnoses },
            updated_diagnoses: { count: 1, items: updated_diagnoses },
            completed_diagnoses: { count: 2, items: completed_diagnoses.reverse },
            matches_count: 3
          }
        end

        before do
          create :diagnosis, step: 1, facility: facility1, created_at: 2.weeks.ago, updated_at: 2.weeks.ago
          create_list :match, 3, need: need

          send_relay_stats_emails
        end

        it 'sends one email with data' do
          expect(RelayMailer).to have_received(:weekly_statistics).once.with(
            territory1_user, information_hash_with_data, an_instance_of(String)
          )
        end

        it 'sends two emails without data' do
          expect(RelayMailer).to have_received(:weekly_statistics).once.with(
            territory2_user1, empty_information_hash, an_instance_of(String)
          )
          expect(RelayMailer).to have_received(:weekly_statistics).once.with(
            territory2_user2, empty_information_hash, an_instance_of(String)
          )
        end
      end
    end
  end
end
