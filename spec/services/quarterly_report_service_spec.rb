# frozen_string_literal: true

require 'rails_helper'
describe QuarterlyReportService do
  describe 'last_quarters' do
    let(:antenne) { create :antenne }
    let(:quarters) { described_class.send(:last_quarters, antenne) }

    context 'with no old matches' do
      it 'return nothing' do
        expect(quarters).to be_nil
      end
    end

    context 'with first matches 4 months ago' do
      let!(:expert) { create :expert_with_users, antenne: antenne }
      let!(:a_match) { create :match, expert: expert, created_at: 3.months.ago }

      it 'return one past quarters' do
        expect(quarters.length).to eq 1
      end
    end

    context 'with first matches a year ago' do
      let!(:expert) { create :expert_with_users, antenne: antenne }
      let!(:a_match) { create :match, expert: expert, created_at: 1.year.ago }

      it 'return 4 past quarters' do
        expect(quarters.length).to eq 4
      end
    end
  end

  describe 'destroy_old_matches_files' do
    let(:antenne) { create :antenne }
    let!(:expert) { create :expert_with_users, antenne: antenne }
    let!(:a_match) { create :match, expert: expert, created_at: 2.years.ago }
    let!(:quarterly_report_ok) { create :quarterly_report, antenne: antenne, start_date: 3.months.ago }
    let!(:quarterly_report_ko) { create :quarterly_report, antenne: antenne, start_date: 2.years.ago }
    let(:quarters) { described_class.send(:last_quarters, antenne) }
    let(:destroy_old_matches) { described_class.send(:destroy_old_matches_files, antenne, quarters) }

    before { quarterly_report_ok.update(start_date: quarters.first.first) }

    it 'delete quarterly_report with date outside of quarters' do
      expect { destroy_old_matches }.to change(QuarterlyReport, :count).by(-1)
      expect(quarterly_report_ok.reload).not_to be_nil
    end
  end
end
