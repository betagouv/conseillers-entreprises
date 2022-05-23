# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerritoryNeedsStatus do
  let(:institution) { create :institution }
  let!(:region_1) { create :territory, :region, code_region: 52 }
  let!(:region_2) { create :territory, :region, code_region: 11 }
  let!(:commune_1) { create :commune, insee_code: '72026', regions: [region_1] }
  let!(:commune_2) { create :commune, insee_code: '72039', regions: [region_1] }
  let!(:commune_3) { create :commune, insee_code: '94068', regions: [region_2] }
  # Antenne dans le territoire
  let!(:antenne_inside_local) { create :antenne, communes: [commune_1], institution: institution }
  let!(:antenne_inside_regional) { create :antenne, :regional, communes: [commune_1], institution: institution }
  let(:expert_inside) { create :expert_with_users, antenne: antenne_inside_local }
  # Antenne en dehors du territoire
  let!(:antenne_outside_1) { create :antenne, communes: [commune_3], institution: institution }
  let(:expert_outside) { create :expert_with_users, antenne: antenne_outside_1 }

  let(:diagnosis) { create :diagnosis_completed }

  describe 'TerritoryNeedsStatus' do
    let!(:need_taking_care_inside) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_inside, status: :taking_care)])
    end
    let!(:need_taking_care_outside) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_outside, status: :taking_care)])
    end
    let!(:need_quo_inside) do
      create(:need, matches: [create(:match, expert: expert_inside, status: :quo)])
    end
    let!(:need_quo_outside) do
      create(:need, matches: [create(:match, expert: expert_outside, status: :quo)])
    end
    let!(:need_not_for_me_inside) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_inside, status: :not_for_me)])
    end
    let!(:need_not_for_me_outside) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_outside, status: :not_for_me)])
    end
    let!(:need_done_inside) do
      create(:need, matches: [create(:match, expert: expert_inside, status: :done)])
    end
    let!(:need_done_outside) do
      create(:need, matches: [create(:match, expert: expert_outside, status: :done)])
    end
    let!(:need_archived_inside) do
      create(:need, matches: [create(:match, expert: expert_inside, status: :quo)], archived_at: Time.zone.now)
    end
    let!(:need_archived_outside) do
      create(:need, matches: [create(:match, expert: expert_outside, status: :quo)], archived_at: Time.zone.now)
    end

    describe 'needs_taking_care' do
      subject { antenne_inside_regional.territory_needs_taking_care }

      it { is_expected.to match_array([need_taking_care_inside]) }
    end

    describe 'needs_quo' do
      subject { antenne_inside_regional.territory_needs_quo }

      it { is_expected.to match_array([need_quo_inside]) }
    end

    describe 'needs_not_for_me' do
      subject { antenne_inside_regional.territory_needs_not_for_me }

      it { is_expected.to match_array([need_not_for_me_inside]) }
    end

    describe 'needs_done' do
      subject { antenne_inside_regional.territory_needs_done }

      it { is_expected.to match_array([need_done_inside]) }
    end

    describe 'needs_archived' do
      subject { antenne_inside_regional.territory_needs_archived }

      it { is_expected.to match_array([need_archived_inside]) }
    end
  end

  describe 'needs_expired' do
    let(:date) { 61.days.ago }
    # 1 - besoin récent non pris en charge ko
    let!(:match_1) { create :match, expert: expert_inside, status: :quo, need: need_1 }
    let(:need_1) { create :need, diagnosis: diagnosis }
    # 2 - besoin de plus de 60 jours non pris en charge ok
    let!(:match_2) { travel_to(date) { create :match, expert: expert_inside, status: :quo, need: need_2 } }
    let(:need_2) { create :need, diagnosis: diagnosis }
    # 3 - besoin récent non pris en charge et archivé ko
    let!(:match_3) { create :match, expert: expert_inside, status: :quo, need: need_3 }
    let(:need_3) { create :need, diagnosis: diagnosis, archived_at: Time.zone.now }
    # 4 - besoin de plus de 60 jours non pris en charge et archivé ok
    let!(:match_4) { travel_to(date) { create :match, expert: expert_inside, status: :quo, need: need_4 } }
    let(:need_4) { create(:need, diagnosis: diagnosis, archived_at: Time.zone.now) }
    # 5 - besoin récent pris en charge ko
    let!(:match_5) { create :match, expert: expert_inside, status: :taking_care, need: need_5 }
    let(:need_5) { create :need, diagnosis: diagnosis }
    # 6 - besoin de plus de 60 jours pris en charge ko
    let!(:match_6) { travel_to(date) { create :match, expert: expert_inside, status: :taking_care, need: need_6 } }
    let(:need_6) { create :need, diagnosis: diagnosis }

    subject { antenne_inside_regional.territory_needs_expired }

    it { is_expected.to match_array([need_2, need_4]) }
  end
end
