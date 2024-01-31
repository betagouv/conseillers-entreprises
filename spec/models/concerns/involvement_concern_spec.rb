# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvolvementConcern do
  let(:current_expert) { create :expert, users: [user] }
  let(:other_expert) { create :expert }
  let(:user) { create :user }
  let(:diagnosis) { create :diagnosis_completed }

  describe 'InvolvementConcern' do
    let!(:need_quo) do
      create(:need, matches: [create(:match, expert: current_expert, status: :quo)])
    end
    let!(:need_other_refused) do
      create(:need, matches: [
        create(:match, expert: current_expert, status: :quo),
        create(:match, expert: other_expert, status: :not_for_me)
      ])
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
    let!(:need_taking_care) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, status: :taking_care)])
    end
    let!(:need_quo_old) do
      create(:need, matches: [create(:match, expert: current_expert, status: :quo, sent_at: 46.days.ago)])
    end
    let!(:need_other_done_old) do
      create(:need, matches: [
        create(:match, expert: current_expert, status: :quo, sent_at: 46.days.ago),
        create(:match, expert: other_expert, status: :done, sent_at: 46.days.ago)
      ])
    end
    let!(:need_other_refused_old) do
      create(:need, matches: [
        create(:match, expert: current_expert, status: :quo, sent_at: 46.days.ago),
        create(:match, expert: other_expert, status: :not_for_me, sent_at: 46.days.ago)
      ])
    end
    let!(:need_not_for_me) do
      create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, status: :not_for_me)])
    end
    let!(:need_done) do
      create(:need, matches: [create(:match, expert: current_expert, status: :done)])
    end

    describe 'needs_taking_care' do
      subject { user.needs_taking_care }

      it { is_expected.to contain_exactly(need_taking_care) }
    end

    describe 'needs_quo' do
      subject { user.needs_quo }

      it { is_expected.to contain_exactly(need_quo, need_other_taking_care, need_other_done, need_other_refused, need_quo_old, need_other_done_old, need_other_refused_old) }
    end

    describe 'needs_quo_active' do
      subject { user.needs_quo_active }

      it { is_expected.to contain_exactly(need_quo, need_other_taking_care, need_other_done, need_other_refused) }
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

    describe 'needs_expired' do
      subject { user.needs_expired }

      it { is_expected.to contain_exactly(need_quo_old, need_other_done_old, need_other_refused_old) }
    end
  end
end
