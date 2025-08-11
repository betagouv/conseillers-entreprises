require 'rails_helper'
describe ActivityReports::Generate::AntenneMatches do
  describe 'generate_files' do
    let(:antenne) { create :antenne }
    let!(:expert) { create :expert_with_users, antenne: antenne }
    let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: 1.month.ago) }
    let(:quarters) { described_class.new(antenne).send(:last_periods) }
    let(:generate_files) { described_class.new(antenne).send(:generate_files, quarters.first) }

    it 'create activity_report' do
      expect { generate_files }.to change(ActivityReport, :count).by(1)
      expect(ActivityReport.last.category).to eq('matches')
    end
  end

  describe 'destroy_old_files' do
    let(:antenne) { create :antenne }
    let!(:expert) { create :expert_with_users, antenne: antenne }
    let!(:a_match) { create :match, expert: expert, need: create(:need, created_at: 2.years.ago) }
    let!(:activity_report_ok) { create :activity_report, :category_matches, reportable: antenne, start_date: 18.months.ago }
    let!(:activity_report_ko) { create :activity_report, :category_matches, reportable: antenne, start_date: 3.years.ago }
    let!(:activity_report_ko_2) { create :activity_report, :category_stats, reportable: antenne, start_date: 18.months.ago }
    let(:quarters) { described_class.new(antenne).send(:last_periods) }
    let(:destroy_old_report) { described_class.new(antenne).send(:destroy_old_files, quarters) }

    before { activity_report_ok.update(start_date: quarters.first.first) }

    it 'delete activity_report with date outside of quarters' do
      expect { destroy_old_report }.to change(ActivityReport, :count).by(-1)
      expect(activity_report_ok.reload).not_to be_nil
    end
  end
end
