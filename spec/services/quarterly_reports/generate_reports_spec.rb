# frozen_string_literal: true

require 'rails_helper'
describe QuarterlyReports::GenerateReports do
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

      context 'with first national matches a three years ago' do
        let!(:expert) { create :expert_with_users, antenne: antenne }
        let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: 3.years.ago) }
        let!(:other_match) { create :match, expert: create(:expert, antenne: local_antenne), need: create(:need, created_at: 5.months.ago) }

        it('return only current and last year quarters') do
          expect(quarters.last.first.strftime('%Y-%m-%d')).to eq 1.year.ago.beginning_of_year.strftime('%Y-%m-%d')
          expect(quarters.length).to be > 4
        end
      end
    end
  end

  describe 'destroy_old_report_files' do
    let(:antenne) { create :antenne }
    let!(:expert) { create :expert_with_users, antenne: antenne }
    let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: 2.years.ago) }
    let!(:quarterly_report_ok) { create :quarterly_report, :category_matches, antenne: antenne, start_date: 18.months.ago }
    let!(:quarterly_report_ko) { create :quarterly_report, :category_matches, antenne: antenne, start_date: 3.years.ago }
    let(:quarters) { described_class.new(antenne).send(:last_quarters) }
    let(:destroy_old_report) { described_class.new(antenne).send(:destroy_old_report_files, quarters) }

    before { quarterly_report_ok.update(start_date: quarters.first.first) }

    it 'delete quarterly_report with date outside of quarters' do
      expect { destroy_old_report }.to change(QuarterlyReport, :count).by(-1)
      expect(quarterly_report_ok.reload).not_to be_nil
    end
  end
end
