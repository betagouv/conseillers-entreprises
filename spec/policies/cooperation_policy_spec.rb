require 'rails_helper'

RSpec.describe CooperationPolicy, type: :policy do
  subject { described_class }

  permissions :show_navbar? do
    context "grants access if user is a cooperation manager" do
      let(:user) { create :user, :cooperation_manager }

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

  permissions :show_navbar_cooperation_matches? do
    let(:cooperation) { create :cooperation, display_matches_stats: display_matches_stats }

    context "grants access if user manages a display_matches_stats cooperation" do
      let(:display_matches_stats) { true }
      let(:user) { create :user, :cooperation_manager, managed_cooperations: [cooperation] }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user) }
    end

    context "denies access if user manages another cooperation" do
      let(:display_matches_stats) { false }
      let(:user) { create :user, :cooperation_manager, managed_cooperations: [cooperation] }

      it { is_expected.not_to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end
  end

  permissions :index? do
    let(:cooperation) { create :cooperation }

    context "grants access if cooperation is in user managed cooperations" do
      let(:user) { create :user, :cooperation_manager }

      it { is_expected.to permit(user) }
    end

    context "grant access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end
  end

  permissions :manage? do
    let(:cooperation) { create :cooperation }

    context "grant access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, cooperation) }
    end

    context "grants access if user manages this cooperation" do
      let(:user) { create :user, :cooperation_manager, managed_cooperations: [cooperation] }

      it { is_expected.to permit(user, cooperation) }
    end

    context "denies access if user manages another cooperation" do
      let(:user) { create :user, :cooperation_manager }

      it { is_expected.not_to permit(user, cooperation) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, cooperation) }
    end
  end
end
