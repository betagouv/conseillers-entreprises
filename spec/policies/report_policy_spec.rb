require 'rails_helper'

RSpec.describe ReportPolicy, :aggregate_failures, type: :policy do
  subject { described_class }

  let(:antenne) { create :antenne }

  let(:admin) { create :user, :admin }
  let(:manager) { create :user, :manager, managed_antennes: [antenne] }
  let(:sponsor) { create :user, :sponsor, sponsored_institutions: [antenne.institution] }
  let(:other_user) { create :user }

  permissions :index? do
    it "grants access to admins, managers and sponsors" do
      is_expected.to permit(admin)
      is_expected.to permit(manager)
      is_expected.to permit(sponsor)
      is_expected.not_to permit(other_user)
    end
  end

  permissions :stats? do
    it "grants access to admins, managers and sponsors of the antenne" do
      is_expected.to permit(admin, antenne)
      is_expected.to permit(manager, antenne)
      is_expected.to permit(sponsor, antenne)
      is_expected.not_to permit(other_user)
    end
  end

  permissions :matches? do
    it "grants access to admins and managers of the antenne" do
      is_expected.to permit(admin, antenne)
      is_expected.to permit(manager, antenne)
      is_expected.not_to permit(sponsor, antenne)
      is_expected.not_to permit(other_user, antenne)
    end
  end
end
