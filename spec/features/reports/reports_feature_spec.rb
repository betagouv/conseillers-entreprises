require 'rails_helper'

describe 'reports' do
  login_user
  let!(:antenne1) { create :antenne, name: "Antenne A", managers: [current_user] }
  let!(:antenne2) { create :antenne, name: "Antenne B", managers: [current_user] }

  describe 'stats' do
    let!(:category_stats1) { create :activity_report, :category_stats, reportable: antenne1, start_date: Date.new(2024, 01, 01), end_date: Date.new(2024, 03, 31) }
    let!(:category_stats2) { create :activity_report, :category_stats, reportable: antenne1, start_date: Date.new(2024, 04, 01), end_date: Date.new(2024, 06, 30) }

    it 'display the list of activity reports' do
      visit stats_reports_path
      expect(page.html).to include I18n.t('reports.stats.title', antenne: antenne1.name)
      expect(page.html).to include antenne1.name
      expect(page).to have_css('.fr-accordion', count: 2)
      expect(page).to have_css('.fr-download__link', count: 2)
    end
  end

  describe 'matches' do
    let!(:category_matches1) { create :activity_report, :category_matches, reportable: antenne1, start_date: Date.new(2024, 01, 01), end_date: Date.new(2024, 01, 31) }
    let!(:category_matches2) { create :activity_report, :category_matches, reportable: antenne1, start_date: Date.new(2024, 02, 01), end_date: Date.new(2024, 02, 28) }
    let!(:category_matches3) { create :activity_report, :category_matches, reportable: antenne1, start_date: Date.new(2023, 12, 01), end_date: Date.new(2023, 12, 31) }

    it 'display the list of activity reports' do
      visit matches_reports_path
      expect(page.html).to include I18n.t('reports.matches.title', antenne: antenne1.name)
      expect(page.html).to include antenne1.name
      expect(page).to have_css('.fr-accordion', count: 2)
      expect(page).to have_css('.fr-download__link', count: 3)
    end
  end
end
