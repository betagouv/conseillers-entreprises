require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:user) { nil }

  subject { described_class }

  permissions :admin? do
    context "grants access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end
  end

  permissions :manager? do
    context "grants access if user is a manager" do
      let(:user) { create :user, :manager }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end
  end
end
