require 'rails_helper'
describe ActivityReports::CooperationStats do
  describe '#perform' do
    let(:cooperation) { create :cooperation }
    let(:generator) { described_class.new(cooperation) }

    around { |example| travel_to('10/07/2025'.to_date, &example) }

    before do
      # Set up a cooperation with activity and existing reports, except for the last quarter
      create :need, created_at: 2.years.ago, solicitation: create(:solicitation, cooperation: cooperation)
      reports = build_list(:activity_report, 7, :category_cooperation) do |report, index|
        report.period = (3 * index).months.before(6.months.ago).all_quarter
      end
      cooperation.activity_reports << reports
    end

    it 'creates new and destroys old reports' do
      # reports should include all quarters of 2024 and first two quarters of 2025
      expect(generator.reports_periods_with_data.count).to eq 6
      expect(generator.missing_reports_periods.count).to eq 1
      expect(generator.expired_reports.count).to eq 2

      old_reports_ids = generator.reports.ids
      generator.perform

      new_reports = generator.reports.order(:start_date)
      expect(new_reports.count).to eq 6
      expect((new_reports.ids - old_reports_ids).size).to eq 1
      expect((old_reports_ids - new_reports.ids).size).to eq 2
      expect(new_reports.first.period).to eq '01/2024'.to_date.all_quarter
      expect(new_reports.last.period).to eq '04/2025'.to_date.all_quarter
    end
  end
end
