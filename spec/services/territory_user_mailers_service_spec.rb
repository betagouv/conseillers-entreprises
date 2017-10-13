# frozen_string_literal: true

require 'rails_helper'

describe TerritoryUserMailersService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe 'send_statistics_email' do
    subject(:send_statistics_email) { described_class.send_statistics_email }

    let(:not_admin_user) { create :user, is_admin: false }

    before do
      allow(TerritoryUserMailer).to receive(:delay) { TerritoryUserMailer }
      allow(TerritoryUserMailer).to receive(:weekly_statistics).and_call_original
    end

    describe 'email method parameters' do
      let(:territory) { create_list :territory, 2 }
      let!(:territory1_user) { create :territory_user, territory: territory.first }

      let(:territory_city1) { create :territory_city, territory: territory.first }
      let(:facility1) { create :facility, city_code: territory_city1.city_code }
      let(:visit1) { create :visit, facility: facility1 }

      let(:empty_information_hash) do
        {
          created_diagnoses: { count: 0, items: [] },
          updated_diagnoses: { count: 0, items: [] },
          completed_diagnoses: { count: 0, items: [] },
          contacted_experts_count: 0
        }
      end

      context 'no data' do
        before { send_statistics_email }

        it 'sends one email' do
          expect(TerritoryUserMailer).to have_received(:weekly_statistics).once.with(
            territory1_user, empty_information_hash, an_instance_of(String)
          )
        end
      end

      context 'some data' do
        let!(:territory2_user1) { create :territory_user, territory: territory.last }
        let!(:territory2_user2) { create :territory_user, territory: territory.last }

        let(:territory_city2) { create :territory_city, territory: territory.last }
        let(:facility2) { create :facility, city_code: territory_city2.city_code }
        let(:visit2) { create :visit, facility: facility2 }

        let(:created_diagnoses) { create_list :diagnosis, 1, step: 1, visit: visit1 }
        let(:completed_diagnoses) { create_list :diagnosis, 2, step: 5, visit: visit1 }
        let(:diagnosed_need) { create :diagnosed_need, diagnosis: completed_diagnoses.first }
        let(:updated_diagnoses) do
          create_list :diagnosis, 1, step: 4, visit: visit1, created_at: 2.weeks.ago, updated_at: 1.hour.ago
        end

        let!(:information_hash_with_data) do
          {
            created_diagnoses: { count: 1, items: created_diagnoses },
            updated_diagnoses: { count: 1, items: updated_diagnoses },
            completed_diagnoses: { count: 2, items: completed_diagnoses.reverse },
            contacted_experts_count: 3
          }
        end

        before do
          create :diagnosis, step: 1, visit: visit1, created_at: 2.weeks.ago, updated_at: 2.weeks.ago
          create_list :selected_assistance_expert, 3, diagnosed_need: diagnosed_need

          send_statistics_email
        end

        it 'sends one email with data' do
          expect(TerritoryUserMailer).to have_received(:weekly_statistics).once.with(
            territory1_user, information_hash_with_data, an_instance_of(String)
          )
        end

        it 'sends two emails without data' do
          expect(TerritoryUserMailer).to have_received(:weekly_statistics).once.with(
            territory2_user1, empty_information_hash, an_instance_of(String)
          )
          expect(TerritoryUserMailer).to have_received(:weekly_statistics).once.with(
            territory2_user2, empty_information_hash, an_instance_of(String)
          )
        end
      end
    end
  end
end
