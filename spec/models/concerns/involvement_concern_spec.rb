# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvolvementConcern do
  let(:current_expert) { create :expert, users: [user] }
  let(:other_expert) { create :expert }
  let(:user) { create :user }
  let(:diagnosis) { create :diagnosis_completed }

  describe 'InvolvementConcern' do
    let!(:need_taking_care) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, status: :taking_care)])
    end
    let!(:need_quo) do
      create(:need, matches: [create(:match, expert: current_expert, status: :quo)])
    end
    let!(:need_not_for_me) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, status: :not_for_me)])
    end
    let!(:need_done) do
      create(:need, matches: [create(:match, expert: current_expert, status: :done)])
    end
    let!(:need_archived) do
      create(:need, matches: [create(:match, expert: current_expert, status: :quo)], archived_at: Time.zone.now)
    end
    let!(:need_other_taking_care) do
      create(:need, diagnosis: diagnosis, matches: [
        create(:match, expert: current_expert, status: :quo),
        create(:match, expert: other_expert, status: :taking_care)
      ])
    end
    let!(:need_other_done) do
      create(:need, diagnosis: diagnosis, matches: [
        create(:match, expert: current_expert, status: :quo),
        create(:match, expert: other_expert, status: :done)
      ])
    end

    describe 'needs_taking_care' do
      subject { user.needs_taking_care }

      it { is_expected.to contain_exactly(need_taking_care) }
    end

    describe 'needs_quo' do
      subject { user.needs_quo }

      it { is_expected.to contain_exactly(need_quo, need_other_taking_care, need_other_done) }
    end

    describe 'needs_others_taking_care' do
      subject { user.needs_others_taking_care }

      it { is_expected.to contain_exactly(need_other_taking_care) }
    end

    describe 'needs_not_for_me' do
      subject { user.needs_not_for_me }

      it { is_expected.to contain_exactly(need_not_for_me) }
    end

    describe 'needs_done' do
      subject { user.needs_done }

      it { is_expected.to contain_exactly(need_done) }
    end

    describe 'needs_archived' do
      # besoin non pris en charge et avec un match de l’expert archivé
      let!(:need_quo_expert_match_archived) do
        matches = [create(:match, expert: current_expert, status: :quo, archived_at: Time.zone.now), create(:match, status: :quo)]
        create(:need, diagnosis: create(:diagnosis_completed), matches: matches)
      end
      # besoin non pris en charge et avec un match d’un autre expert archivé
      let!(:need_quo_another_expert_match_archived) do
        matches = [create(:match, expert: current_expert, status: :quo), create(:match, status: :quo, archived_at: Time.zone.now)]
        create(:need, diagnosis: create(:diagnosis_completed), matches: matches)
      end
      # besoin refusé par l’expert et non archivé
      let!(:need_refused_not_archived) do
        create(:need, diagnosis: create(:diagnosis_completed), matches: [create(:match, expert: current_expert, status: :quo)])
      end

      subject { user.needs_archived }

      it { is_expected.to contain_exactly(need_archived, need_quo_expert_match_archived) }
    end
  end

  describe 'needs_expired' do
    let(:date) { 61.days.ago }
    # 1 - besoin récent non pris en charge ko
    let!(:match_1) { create :match, expert: current_expert, status: :quo, need: need_1 }
    let(:need_1) { create :need, diagnosis: diagnosis }
    # 2 - besoin de plus de 60 jours non pris en charge ok
    let!(:match_2) { travel_to(date) { create :match, expert: current_expert, status: :quo, need: need_2 } }
    let(:need_2) { create :need, diagnosis: diagnosis }
    # 3 - besoin récent non pris en charge et archivé ko
    let!(:match_3) { create :match, expert: current_expert, status: :quo, need: need_3 }
    let(:need_3) { create :need, diagnosis: diagnosis, archived_at: Time.zone.now }
    # 4 - besoin de plus de 60 jours non pris en charge et archivé ok
    let!(:match_4) { travel_to(date) { create :match, expert: current_expert, status: :quo, need: need_4 } }
    let(:need_4) { create(:need, diagnosis: diagnosis, archived_at: Time.zone.now) }
    # 5 - besoin récent pris en charge ko
    let!(:match_5) { create :match, expert: current_expert, status: :taking_care, need: need_5 }
    let(:need_5) { create :need, diagnosis: diagnosis }
    # 6 - besoin de plus de 60 jours pris en charge ko
    let!(:match_6) { travel_to(date) { create :match, expert: current_expert, status: :taking_care, need: need_6 } }
    let(:need_6) { create :need, diagnosis: diagnosis }

    subject { user.needs_expired }

    it { is_expected.to contain_exactly(need_2, need_4) }
  end
end
