require 'rails_helper'

RSpec.describe ReportPolicy, type: :policy do
  subject { described_class }

  permissions :index? do
    context "grants access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user) }
    end

    context "grants access if user is a manager" do
      let(:user) { create :user, :manager }

      it { is_expected.to permit(user) }
    end

    context "grants access if user is a sponsor" do
      let(:user) { create :user, :sponsor }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end
  end

  permissions :stats? do
    let(:antenne) { create :antenne }

    context "grant access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, antenne) }
    end

    context "grants access if antenne is in user managed antennes" do
      let(:user) { create :user, :manager, managed_antennes: [antenne] }

      it { is_expected.to permit(user, antenne) }
    end

    context "grants access if user is a sponsor" do
      let(:user) { create :user, :sponsor, sponsored_institutions: [antenne.institution] }

      it { is_expected.to permit(user, antenne) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, antenne) }
    end
  end

  permissions :matches? do
    let(:antenne) { create :antenne }

    context "grant access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, antenne) }
    end

    context "grants access if antenne is in user managed antennes" do
      let(:user) { create :user, :manager, managed_antennes: [antenne] }

      it { is_expected.to permit(user, antenne) }
    end

    context "denies access if user is a sponsor" do
      let(:user) { create :user, :sponsor, sponsored_institutions: [antenne.institution] }

      it { is_expected.not_to permit(user) }
    end


    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, antenne) }
    end
  end
end
