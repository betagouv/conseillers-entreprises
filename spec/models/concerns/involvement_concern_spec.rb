# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvolvementConcern do
  let(:diagnosis) { create :diagnosis_completed }
  let!(:need_taking_care) do
    create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, status: :taking_care)])
  end
  let!(:need_quo) do
    create(:need, matches: [create(:match, expert: current_expert, status: :quo)])
  end
  let!(:need_rejected) do
    create(:need, diagnosis: diagnosis, matches: [create(:match, expert: current_expert, status: :not_for_me)])
  end
  let!(:need_done) do
    create(:need, matches: [create(:match, expert: current_expert, status: :done)])
  end
  let!(:need_archived) do
    create(:need, matches: [create(:match, expert: current_expert, status: :quo)], archived_at: Time.zone.now)
  end
  let!(:need_other_taking_care) do
    create(:need, matches: [
      create(:match, expert: current_expert, status: :quo),
      create(:match, expert: other_expert, status: :taking_care)
    ])
  end

  let(:current_expert) { create :expert, users: [user] }
  let(:other_expert) { create :expert }
  let(:user) { create :user }

  describe 'needs_taking_care' do
    subject { user.needs_taking_care }

    it { is_expected.to contain_exactly(need_taking_care) }
  end

  describe 'needs_quo' do
    subject { user.needs_quo }

    it { is_expected.to contain_exactly(need_quo) }
  end

  describe 'needs_others_taking_care' do
    subject { user.needs_others_taking_care }

    it { is_expected.to contain_exactly(need_other_taking_care) }
  end

  describe 'needs_rejected' do
    subject { user.needs_rejected }

    it { is_expected.to contain_exactly(need_rejected) }
  end

  describe 'needs_done' do
    subject { user.needs_done }

    it { is_expected.to contain_exactly(need_done) }
  end

  describe 'needs_archived' do
    subject { user.needs_archived }

    it { is_expected.to contain_exactly(need_archived) }
  end
end
