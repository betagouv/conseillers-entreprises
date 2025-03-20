# frozen_string_literal: true

require 'rails_helper'

describe 'reports' do
  describe 'index' do
    login_user
    let!(:antenne1) { create :antenne, name: "Antenne A", managers: [current_user] }
    let!(:antenne2) { create :antenne, name: "Antenne B", managers: [current_user] }
    let!(:category_matches1) { create :activity_report, :category_matches, reportable: antenne1, start_date: Date.new(2021, 01, 01), end_date: Date.new(2021, 03, 31) }
    let!(:category_matches2) { create :activity_report, :category_matches, reportable: antenne1, start_date: Date.new(2021, 04, 01), end_date: Date.new(2021, 06, 30) }
    let!(:category_stats1) { create :activity_report, :category_stats, reportable: antenne1, start_date: Date.new(2021, 01, 01), end_date: Date.new(2021, 03, 31) }
    let!(:category_stats2) { create :activity_report, :category_stats, reportable: antenne1, start_date: Date.new(2021, 04, 01), end_date: Date.new(2021, 06, 30) }
    let!(:quarters) { antenne1.activity_reports.order(start_date: :desc).pluck(:start_date, :end_date).uniq }

    it 'display the list of quarterly reports' do
      visit reports_path
      expect(page.html).to include I18n.t('reports.index.title', antenne: antenne1.name)
      expect(page.html).to include antenne1.name
      expect(page).to have_css('.fr-accordion', count: 2)
      expect(page).to have_css('.fr-download__link', count: 4)
    end
  end
end
