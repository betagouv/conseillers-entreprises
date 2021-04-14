require 'rails_helper'

RSpec.describe FacilityPolicy, type: :policy do
  let(:facility) { create :facility }

  subject { described_class }

  permissions :show_needs_history? do
    context 'user is admin' do
      let(:user) { create :user, is_admin: true }

      describe "grants access if there is any completed need for a facility" do
        let!(:diagnosis) { create :diagnosis_completed, facility: facility }
        let!(:another_diagnosis) { create :diagnosis_completed, facility: facility }

        it { is_expected.to permit(user, facility) }
      end

      describe "denies access if there is no completed need for a facility" do
        let!(:diagnosis) { create :diagnosis, facility: facility }

        it { is_expected.not_to permit(user, facility) }
      end
    end

    context 'User is not admin' do
      let(:user) { create :user }
      let(:expert) { user.experts.first }
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need_with_matches, diagnosis: diagnosis, status: :quo }

      describe "grants access if user is in user.received_needs and there is any need for a facility" do
        let!(:a_match) { create :match, need: need, expert: expert, status: :quo }

        it { is_expected.to permit(user, facility) }
      end

      describe "denies access if user is not in user.received_needs and their is many needs for a facility" do
        let!(:a_match) { create :match, need: need, status: :quo }

        it { is_expected.not_to permit(user, facility) }
      end
    end
  end
end
