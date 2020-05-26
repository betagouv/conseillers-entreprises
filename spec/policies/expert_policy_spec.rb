require 'rails_helper'

RSpec.describe ExpertPolicy, type: :policy do
  let(:user) { nil }
  let(:expert) { create :expert }

  subject { described_class }

  permissions :edit? do
    context "grants access if user is an admin" do
      let(:user) { create :user, is_admin: true }

      it { is_expected.to permit(user, expert) }
    end

    context "grants access if user is in expert.users" do
      let(:user) { expert.users.first }

      it { is_expected.to permit(user, expert) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, expert) }
    end
  end

  permissions :update? do
    context "grants access if user is an admin" do
      let(:user) { create :user, is_admin: true }

      it { is_expected.to permit(user, expert) }
    end

    context "grants access if user is in expert.users" do
      let(:user) { expert.users.first }

      it { is_expected.to permit(user, expert) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, expert) }
    end
  end

  permissions :update_subjects? do
    let(:user) { expert.users.first }

    context "grants access if expert can edit own subjects" do
      before { expert.can_edit_own_subjects = true }

      it { is_expected.to permit(user, expert) }
    end

    context "denies access if expert cant edit own subjects" do
      before { expert.can_edit_own_subjects = false }

      it { is_expected.not_to permit(user, expert) }
    end
  end
end
