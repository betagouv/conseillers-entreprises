require 'rails_helper'

RSpec.describe AntennePolicy, type: :policy do
  let(:user) { nil }
  let(:antenne) { create :antenne }

  subject { described_class }

  permissions :show_manager? do
    context "grants access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, antenne) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, antenne) }
    end
  end

  permissions :show? do
    context "grants access if user is in the antenne" do
      let(:user) { create :user, antenne: antenne }

      it { is_expected.to permit(user, antenne) }
    end

    context "grants access if user is manager of the antenne" do
      let(:user) { create :user, :manager }

      before { user.managed_antennes << antenne }

      it { is_expected.to permit(user, antenne) }
    end

    context "denies access if user is a manager of another antenne" do
      let(:user) { create :user, :manager }

      it { is_expected.not_to permit(user, antenne) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, antenne) }
    end
  end
end
