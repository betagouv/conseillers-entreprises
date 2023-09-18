# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'stats/public/index' do
  describe "index" do
    let(:need00) { create :need }
    let(:need01) { create :need_with_matches }
    let(:need02) { create :need_with_matches }
    let(:start_date) { 6.months.ago.beginning_of_month.to_date }
    let(:end_date) { Date.today }

    it "displays coherent needs counts" do
      assign(:stats, { start_date: start_date, end_date: end_date })
      assign(:main_stat, Stats::Public::ExchangeWithExpertColumnStats.new({ start_date: start_date, end_date: end_date }))
      assign(:graph_names, %w[solicitations solicitations_diagnoses exchange_with_expert needs_done_from_exchange taking_care themes companies_by_employees companies_by_naf_code])

      render

      expect(rendered).to have_content("Statistiques d’utilisation")
      expect(rendered).to have_selector('.fr-col-12.card.stats', count: 8)
      expect(rendered).to have_selector('.fr-container.main-stat', count: 1)
    end
  end
end
