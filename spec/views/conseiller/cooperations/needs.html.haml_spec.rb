require 'rails_helper'

RSpec.describe 'conseiller/cooperations/needs' do
  describe "index" do
    let(:cooperation) { create :cooperation }
    let(:need01) { create :need_with_matches, diagnosis: create(:diagnosis, solicitation: create(:solicitation, cooperation: cooperation)) }
    let(:need02) { create :need_with_matches, diagnosis: create(:diagnosis, solicitation: create(:solicitation, cooperation: cooperation)) }
    let(:start_date) { 6.months.ago.beginning_of_month.to_date }
    let(:end_date) { Date.today }

    it "displays page without errors" do
      assign(:stats_params, { start_date: start_date, end_date: end_date })
      assign(:filters, { themes: [], subjects: [], regions: [] })
      assign(:cooperation, cooperation)
      assign(:charts_names, %w[
        solicitations_completed solicitations_diagnoses
        needs_positioning needs_done needs_done_no_help needs_done_not_reachable needs_not_for_me
        needs_taking_care needs_themes_all needs_subjects_all companies_by_employees companies_by_naf_code
      ])

      render

      expect(rendered).to have_content("Pilotage par besoin")
      expect(rendered).to have_css('.card-title', count: 12)
    end
  end
end
