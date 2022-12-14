# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'stats/team/index' do
  context 'with default params' do
    let(:need00) { create :need }
    let(:need01) { create :need_with_matches }
    let(:need02) { create :need_with_matches }
    let(:start_date) { 6.months.ago.beginning_of_month.to_date }
    let(:end_date) { Date.today }

    it "displays correctly public stats" do
      assign(:stats, Stats::Public::All.new({ start_date: start_date, end_date: end_date }))
      assign(:charts_names, [
        :solicitations, :solicitations_diagnoses,
        :exchange_with_expert, :taking_care, :themes, :companies_by_employees, :companies_by_naf_code
      ])
      assign(:institution_antennes, [])
      assign(:action_name, 'public')
      allow(view).to receive(:action_name).and_return("public")

      render

      expect(rendered).to have_selector('h1', text: t('stats.team.public'))
      expect(rendered).to have_selector('.fr-col-12.card.stats', count: 7)
    end

    it "displays correctly needs stats" do
      assign(:stats, Stats::Needs::All.new({ start_date: start_date, end_date: end_date }))
      assign(:charts_names, [
        :transmitted_less_than_72h_stats, :needs_done, :needs_done_no_help, :needs_done_not_reachable,
        :needs_not_for_me, :needs_abandoned
      ])
      assign(:institution_antennes, [])
      assign(:action_name, 'needs')
      allow(view).to receive(:action_name).and_return("needs")

      render

      expect(rendered).to have_selector('h1', text: t('stats.team.needs'))
      expect(rendered).to have_selector('.fr-col-12.card.stats', count: 6)
    end

    it "displays correctly matches stats" do
      assign(:stats, Stats::Matches::All.new({ start_date: start_date, end_date: end_date }))
      assign(:charts_names, [
        :positioning_rate, :taking_care_rate_stats, :done_rate_stats,
        :done_no_help_rate_stats, :done_not_reachable_rate_stats, :not_for_me_rate_stats,
        :not_positioning_rate
      ])
      assign(:institution_antennes, [])
      allow(view).to receive(:action_name).and_return("matches")

      render

      expect(rendered).to have_selector('h1', text: t('stats.team.matches'))
      expect(rendered).to have_selector('.fr-col-12.card.stats', count: 7)
    end
  end
end
