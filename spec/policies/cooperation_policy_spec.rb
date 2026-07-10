require 'rails_helper'

RSpec.describe CooperationPolicy, :aggregate_failures, type: :policy do
  subject { described_class }

  let(:cooperation) { create :cooperation }

  let(:admin) { create :user, :admin }
  let(:manager) { create :user, :cooperation_manager, managed_cooperations: [cooperation] }
  let(:other_user) { create :user }

  permissions :index? do
    it "grants access to admins and cooperation managers" do
      is_expected.to permit(admin)
      is_expected.to permit(manager)
      is_expected.not_to permit(other_user)
    end
  end

  permissions :needs?, :reports? do
    it "grants access to admins and managers of the cooperation" do
      is_expected.to permit(admin, cooperation)
      is_expected.to permit(manager, cooperation)
      is_expected.not_to permit(other_user, cooperation)
    end
  end

  permissions :matches? do
    context "the cooperation does not display matches stats" do
      it "grants access to nobody" do
        is_expected.not_to permit(admin, cooperation)
        is_expected.not_to permit(manager, cooperation)
        is_expected.not_to permit(other_user, cooperation)
      end
    end

    context "the cooperation displays matches stats" do
      let(:cooperation) { create :cooperation, display_matches_stats: true }

      it "grants access to admins and managers of the cooperation" do
        is_expected.to permit(admin, cooperation)
        is_expected.to permit(manager, cooperation)
        is_expected.not_to permit(other_user, cooperation)
      end
    end
  end

  permissions :solicitations? do
    context "the cooperation does not display solicitations stats" do
      it "grants access to nobody" do
        is_expected.not_to permit(admin, cooperation)
        is_expected.not_to permit(manager, cooperation)
        is_expected.not_to permit(other_user, cooperation)
      end
    end

    context "the cooperation displays solicitations stats" do
      let(:cooperation) { create :cooperation, wants_solicitations_export: true }

      it "grants access to admins and managers of the cooperation" do
        is_expected.to permit(admin, cooperation)
        is_expected.to permit(manager, cooperation)
        is_expected.not_to permit(other_user, cooperation)
      end
    end
  end
end
