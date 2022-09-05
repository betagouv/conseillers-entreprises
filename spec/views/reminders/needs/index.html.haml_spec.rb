# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'reminders/needs/index', type: :view do
  describe "archive" do
    login_user
    let!(:action) { :archive }
    let!(:current_date) { Time.zone.now.beginning_of_day }
    let(:thirty_days_ago) { current_date - 45.days }
    let!(:diagnosis_in_progress) { create :diagnosis }
    let!(:diagnosis_mixte) { create :diagnosis_completed }
    let!(:need00) { travel_to(thirty_days_ago) { create :need, diagnosis: diagnosis_in_progress } }
    let!(:need01) { travel_to(thirty_days_ago) { create :need_with_matches, diagnosis:  diagnosis_mixte } }
    let!(:need02) { travel_to(thirty_days_ago) { create :need_with_matches, diagnosis:  diagnosis_mixte, archived_at: current_date } }

    let!(:needs_to_archive) { Need.reminders_to(action).includes(:subject).page(1) }

    it "displays coherent needs counts" do
      assign(:action, action)
      assign(:needs, needs_to_archive)
      assign(:collections_by_status_counts, %i[not_for_me].index_with { |name| Need.archived(false).where(status: name).size })
      assign(:collections_counts, %i[poke recall archive].index_with { |name| Need.reminders_to(name).size })
      assign(:expert_collections_count, %i[critical_rate worrying_rate pending_rate].index_with { |name| PositionningRate::Collection.new(Expert).send(name).distinct.size })
      assign(:territories, Territory.regions.order(:name))

      render

      expect(rendered).to have_content("Région")
      assert_select "a", { count: 1, text: "Archiver" }
    end
  end
end
