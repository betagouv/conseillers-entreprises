# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'stats/team/index', type: :view do
  context 'with default params' do
    let(:need00) { create :need }
    let(:need01) { create :need_with_matches }
    let(:need02) { create :need_with_matches }
    let(:start_date) { 6.months.ago.beginning_of_month.to_date }
    let(:end_date) { Date.today }

    it "displays correctly quality stats" do
      assign(:stats, Stats::Quality::All.new({ start_date: start_date, end_date: end_date }))
      assign(:charts_names, [:needs_done, :needs_done_no_help, :needs_done_not_reachable, :needs_not_for_me, :needs_abandoned])

      render

      expect(rendered).to have_content("Suivi qualité")
    end

    it "displays correctly matches stats" do
      assign(:stats, Stats::Matches::All.new({ start_date: start_date, end_date: end_date }))
      assign(:charts_names, [:transmitted_less_than_72h_stats])

      render

      expect(rendered).to have_content("Mises en relation")
    end
  end
end
