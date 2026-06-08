require 'rails_helper'
describe ActivityReports::AntenneMatches do
  describe '#perform' do
    let(:antenne) { create :antenne, name: "Commune de Paris" }
    let(:generator) { described_class.new(antenne) }

    around { |example| travel_to('10/07/2025'.to_date, &example) }

    before do
      # This antenne has received matches every month for 24 months
      diag = build(:diagnosis)
      needs = build_list(:need, 24, diagnosis: diag) { |need, index| need.created_at = index.months.ago }
      matches = build_list(:match, 24) { |match, index| match.need = needs[index] }
      create(:expert, antenne: antenne, received_matches: matches)

      # Old reports already exists, but the last two months are missing
      reports = build_list(:activity_report, 22, :category_matches, antenne: antenne) do |report, index|
        report.period = index.months.before(3.months.ago).all_month
      end
      antenne.matches_reports << reports
    end

    it 'creates new and destroys old reports' do
      # reports should include all months of 2024 until May 2025.
      expect(generator.reports_periods_with_data.count).to eq 18
      expect(generator.missing_reports_periods.count).to eq 2
      expect(generator.expired_reports.count).to eq 6

      old_reports_ids = generator.reports.ids
      generator.perform

      new_reports = generator.reports.order(:start_date)
      expect(new_reports.count).to eq 18
      expect((new_reports.ids - old_reports_ids).size).to eq 2
      expect((old_reports_ids - new_reports.ids).size).to eq 6
      expect(new_reports.first.period).to eq Date.new(2024,1).all_month
      expect(new_reports.last.period).to eq Date.new(2025,6).all_month
      expect(new_reports.last.file.filename.to_s).to eq 'export-mises-en-relation-commune-de-paris-2025-6.xlsx'
    end
  end
end
