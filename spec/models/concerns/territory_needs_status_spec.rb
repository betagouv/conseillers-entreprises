# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerritoryNeedsStatus do
  let(:institution) { create :institution }
  # Antenne dans le territoire
  let!(:antenne_inside_local) { create :antenne, institution: institution, parent_antenne: antenne_inside_regional }
  let!(:antenne_inside_regional) { create :antenne, :regional, institution: institution }
  let(:expert_inside) { create :expert_with_users, antenne: antenne_inside_local }
  # Antenne en dehors du territoire
  let!(:antenne_outside_1) { create :antenne, institution: institution }
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
    let!(:need_expired_inside) do
      create(:need, matches: [create(:match, expert: expert_inside, status: :quo, sent_at: 46.days.ago)])
    end
    let!(:need_expired_outside) do
      create(:need, matches: [create(:match, expert: expert_outside, status: :quo, sent_at: 46.days.ago)])
    end

    describe 'needs_taking_care' do
      subject { antenne_inside_regional.territory_needs_taking_care }

      it { is_expected.to contain_exactly(need_taking_care_inside) }
    end

    describe 'needs_quo' do
      subject { antenne_inside_regional.territory_needs_quo }

      it { is_expected.to contain_exactly(need_quo_inside, need_expired_inside) }
    end

    describe 'needs_quo_active' do
      subject { antenne_inside_regional.territory_needs_quo_active }

      it { is_expected.to contain_exactly(need_quo_inside) }
    end

    describe 'needs_not_for_me' do
      subject { antenne_inside_regional.territory_needs_not_for_me }

      it { is_expected.to contain_exactly(need_not_for_me_inside) }
    end

    describe 'needs_done' do
      subject { antenne_inside_regional.territory_needs_done }

      it { is_expected.to contain_exactly(need_done_inside) }
    end

    describe 'needs_expired' do
      subject { antenne_inside_regional.territory_needs_expired }

      it { is_expected.to contain_exactly(need_expired_inside) }
    end
  end
end
