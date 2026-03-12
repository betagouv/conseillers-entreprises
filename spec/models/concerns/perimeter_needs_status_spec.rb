require 'rails_helper'

RSpec.describe PerimeterNeedsStatus do
  let(:institution) { create :institution }
  # Antenne dans le territoire
  let!(:antenne_inside_regional) { create :antenne, :regional, institution: institution }
  let!(:antenne_inside_local) { create :antenne, institution: institution, parent_antenne: antenne_inside_regional }
  let(:expert_regional) { create :expert_with_users, antenne: antenne_inside_regional }
  let(:expert_local) { create :expert_with_users, antenne: antenne_inside_local }
  # Antenne en dehors du territoire
  let!(:antenne_outside) { create :antenne, institution: institution }
  let(:expert_outside) { create :expert_with_users, antenne: antenne_outside }

  let(:diagnosis) { create :diagnosis_completed }

  describe 'aggregate: true antenne régionale avec ses antennes locales' do
    let!(:need_taking_care_regional) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_regional, status: :taking_care)])
    end
    let!(:need_taking_care_local) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_local, status: :taking_care)])
    end
    let!(:need_taking_care_outside) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_outside, status: :taking_care)])
    end
    let!(:need_quo_local) do
      create(:need, matches: [create(:match, expert: expert_local, status: :quo)])
    end
    let!(:need_quo_outside) do
      create(:need, matches: [create(:match, expert: expert_outside, status: :quo)])
    end
    let!(:need_not_for_me_local) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_local, status: :not_for_me)])
    end
    let!(:need_done_local) do
      create(:need, matches: [create(:match, expert: expert_local, status: :done)])
    end
    let!(:need_expired_local) do
      create(:need, matches: [create(:match, expert: expert_local, status: :quo, sent_at: 46.days.ago)])
    end

    describe 'territory_needs_taking_care' do
      subject { antenne_inside_regional.territory_needs_taking_care(aggregate: true) }

      it { is_expected.to contain_exactly(need_taking_care_regional, need_taking_care_local) }
    end

    describe 'territory_needs_quo' do
      subject { antenne_inside_regional.territory_needs_quo(aggregate: true) }

      it { is_expected.to contain_exactly(need_quo_local, need_expired_local) }
    end

    describe 'territory_needs_quo_active' do
      subject { antenne_inside_regional.territory_needs_quo_active(aggregate: true) }

      it { is_expected.to contain_exactly(need_quo_local) }
    end

    describe 'territory_needs_not_for_me' do
      subject { antenne_inside_regional.territory_needs_not_for_me(aggregate: true) }

      it { is_expected.to contain_exactly(need_not_for_me_local) }
    end

    describe 'territory_needs_done' do
      subject { antenne_inside_regional.territory_needs_done(aggregate: true) }

      it { is_expected.to contain_exactly(need_done_local) }
    end

    describe 'territory_needs_expired' do
      subject { antenne_inside_regional.territory_needs_expired(aggregate: true) }

      it { is_expected.to contain_exactly(need_expired_local) }
    end
  end

  describe 'aggregate: false antenne régionale seule' do
    let!(:need_taking_care_regional) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_regional, status: :taking_care)])
    end
    let!(:need_taking_care_local) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_local, status: :taking_care)])
    end
    let!(:need_quo_regional) do
      create(:need, matches: [create(:match, expert: expert_regional, status: :quo)])
    end
    let!(:need_not_for_me_regional) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: expert_regional, status: :not_for_me)])
    end
    let!(:need_done_regional) do
      create(:need, matches: [create(:match, expert: expert_regional, status: :done)])
    end
    let!(:need_expired_regional) do
      create(:need, matches: [create(:match, expert: expert_regional, status: :quo, sent_at: 46.days.ago)])
    end

    describe 'territory_needs_taking_care' do
      subject { antenne_inside_regional.territory_needs_taking_care(aggregate: false) }

      it { is_expected.to contain_exactly(need_taking_care_regional) }
    end

    describe 'territory_needs_quo' do
      subject { antenne_inside_regional.territory_needs_quo(aggregate: false) }

      it { is_expected.to contain_exactly(need_quo_regional, need_expired_regional) }
    end

    describe 'territory_needs_quo_active' do
      subject { antenne_inside_regional.territory_needs_quo_active(aggregate: false) }

      it { is_expected.to contain_exactly(need_quo_regional) }
    end

    describe 'territory_needs_not_for_me' do
      subject { antenne_inside_regional.territory_needs_not_for_me(aggregate: false) }

      it { is_expected.to contain_exactly(need_not_for_me_regional) }
    end

    describe 'territory_needs_done' do
      subject { antenne_inside_regional.territory_needs_done(aggregate: false) }

      it { is_expected.to contain_exactly(need_done_regional) }
    end

    describe 'territory_needs_expired' do
      subject { antenne_inside_regional.territory_needs_expired(aggregate: false) }

      it { is_expected.to contain_exactly(need_expired_regional) }
    end
  end
end
