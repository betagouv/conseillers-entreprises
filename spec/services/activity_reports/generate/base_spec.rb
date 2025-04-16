# frozen_string_literal: true

require 'rails_helper'
describe ActivityReports::Generate::Base do
  describe 'last_quarters' do
    let(:quarters) { described_class.new(antenne).send(:last_quarters) }

    context 'local antenne' do
      let(:antenne) { create :antenne, :local }

      context 'with no old matches' do
        it('return nothing') { expect(quarters).to be_nil }
      end

      context 'with first matches 4 months ago' do
        let!(:expert) { create :expert_with_users, antenne: antenne }
        let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: 3.months.ago) }

        it('return one past quarters') { expect(quarters.length).to eq 1 }
      end

      context 'with first matches a year ago' do
        let!(:expert) { create :expert_with_users, antenne: antenne }
        let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: 1.year.ago) }

        it('return 4 past quarters') { expect(quarters.length).to eq 4 }
      end
    end

    context 'national antenne' do
      let(:institution) { create :institution }
      let(:antenne) { create :antenne, :national, institution: institution }
      let(:local_antenne) { create :antenne, :local, institution: institution }

      context 'with first local matches 4 months ago' do
        let!(:expert) { create :expert_with_users, antenne: local_antenne }
        let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: 3.months.ago) }

        it('return one past quarters') { expect(quarters.length).to eq 1 }
      end

      context 'with first national matches a year ago' do
        let!(:expert) { create :expert_with_users, antenne: antenne }
        let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: 1.year.ago) }
        let!(:other_match) { create :match, expert: create(:expert, antenne: local_antenne), need: create(:need, created_at: 5.months.ago) }

        it('return only current and last year quarters') { expect(quarters.length).to eq 4 }
      end

      context 'with old first national matches' do
        let!(:expert) { create :expert_with_users, antenne: antenne }
        let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: Time.zone.local('2021', '06', '13')) }
        let!(:other_match) { create :match, expert: create(:expert, antenne: local_antenne), need: create(:need, created_at: Time.zone.local('2024', '04', '30')) } # 5 months ago

        context 'calculating in T2 N-1' do
          let(:quarters) do
            travel_to(Time.zone.local('2023', '04', '20')) do
              described_class.new(antenne).send(:last_quarters)
            end
          end

          it('returns 5 quarters') { expect(quarters.length).to eq 5 }
        end

        context 'calculating in T3 N-1' do
          let(:quarters) do
            travel_to(Time.zone.local('2023', '07', '20')) do
              described_class.new(antenne).send(:last_quarters)
            end
          end

          it('returns 6 quarters') { expect(quarters.length).to eq 6 }
        end

        context 'calculating in T1 N' do
          let(:quarters) do
            travel_to(Time.zone.local('2024', '01', '20')) do
              described_class.new(antenne).send(:last_quarters)
            end
          end

          it('returns 8 quarters') { expect(quarters.length).to eq 8 }
        end

        context 'calculating in T2 N' do
          let(:quarters) do
            travel_to(Time.zone.local('2024', '04', '20')) do
              described_class.new(antenne).send(:last_quarters)
            end
          end

          it('returns 5 quarters') { expect(quarters.length).to eq 5 }
        end

      end
    end
  end
end
