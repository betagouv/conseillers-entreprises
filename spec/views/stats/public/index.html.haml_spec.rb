# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'stats/public/index', type: :view do
  describe "index" do
    let(:need00) { create :need }
    let(:need01) { create :need_with_matches }
    let(:need02) { create :need_with_matches }
    let(:start_date) { 6.months.ago.beginning_of_month.to_date }
    let(:end_date) { Date.today }

    it "displays coherent needs counts" do
      assign(:stats, Stats::Public::All.new({ start_date: start_date, end_date: end_date }))
      assign(:main_stat, Stats::Public::ExchangeWithExpertColumnStats.new({ start_date: start_date, end_date: end_date }))

      render

      expect(rendered).to have_content("Statistiques d’utilisation")
    end
  end
end
