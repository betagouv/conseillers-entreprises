require 'rails_helper'

RSpec.describe MatchPolicy, type: :policy do
  let(:user) { nil }
  let(:match) { create :match }

  subject { described_class }

  permissions :update? do
    context "grants access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, match) }
    end

    context "grants access if user is a contacted user" do
      let(:user) { match.contacted_users.first }

      it { is_expected.to permit(user, match) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, match) }
    end
  end

  permissions :update_status? do
    context "grants access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, match) }
    end

    context "grant access for manager if match is in a managed antenne" do
      let(:antenne) { match.expert.antenne }
      let(:user) { create :user, :manager, antenne: antenne }

      it { is_expected.to permit(user, match) }
    end

    context "denies access for manager if match is not in a managed antenne" do
      let(:user) { create :user, :manager, antenne: create(:antenne) }

      it { is_expected.not_to permit(user, match) }
    end

    context "denies access if user is a contacted user" do
      let(:user) { match.contacted_users.first }

      it { is_expected.not_to permit(user, match) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, match) }
    end
  end

  permissions :taking_care_by?, :show_inbox? do
    context "grants access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, match) }
    end

    context "denies access if user is a contacted user" do
      let(:user) { match.contacted_users.first }

      it { is_expected.not_to permit(user, match) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, match) }
    end
  end
end
