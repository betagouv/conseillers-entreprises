require 'rails_helper'

RSpec.describe SharedSatisfactionPolicy, type: :policy do
  subject { described_class }

  permissions :show_navbar? do
    context "denies access if user is a manager" do
      let(:user) { create :user, :manager }

      it { is_expected.not_to permit(user) }
    end

    context "grants access if user is a standard user" do
      let(:user) { create :user }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user) }
    end
  end

  permissions :mark_as_seen? do
    let(:shared_satisfaction) { create(:shared_satisfaction, user: record_owner) }
    let(:record_owner) { create(:user) }

    context 'grants access when the user is the owner of the record' do
      let(:user) { record_owner }

      it { is_expected.to permit(user, shared_satisfaction) }
    end

    context 'denies accesswhen the user is not the owner of the record' do
      let(:user) { create(:user) }

      it { is_expected.not_to permit(user, shared_satisfaction) }
    end

    context 'denies access when the user is nil' do
      let(:user) { nil }

      it { is_expected.not_to permit(user, shared_satisfaction) }
    end
  end
end
