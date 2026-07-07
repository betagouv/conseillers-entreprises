require 'rails_helper'

RSpec.describe ReportPolicy, :aggregate_failures, type: :policy do
  subject { described_class }

  let(:antenne) { create :antenne }

  let(:admin) { create :user, :admin }
  let(:manager) { create :user, :manager, managed_antennes: [antenne] }
  let(:sponsor) { create :user, :sponsor, sponsored_institutions: [antenne.institution] }
  let(:other_user) { create :user }

  let(:matches_report) { create :activity_report, :category_matches, reportable: antenne }
  let(:stats_report) { create :activity_report, :category_stats, reportable: antenne }

  permissions :index?, :stats? do
    it "grants access to admins, managers and sponsors" do
      is_expected.to permit(admin)
      is_expected.to permit(manager)
      is_expected.to permit(sponsor)
      is_expected.not_to permit(other_user)
    end
  end

  permissions :matches? do
    it "grants access to admins and managers of the antenne" do
      is_expected.to permit(admin)
      is_expected.to permit(manager)
      is_expected.not_to permit(sponsor)
      is_expected.not_to permit(other_user)
    end
  end

  permissions :download? do
    context "matches report" do
      it "grants access to admins, managers of the antenne" do
        is_expected.to permit(admin, matches_report)
        is_expected.to permit(manager, matches_report)
        is_expected.not_to permit(sponsor, matches_report)
        is_expected.not_to permit(other_user, matches_report)
      end
    end

    context "stats report" do
      it "grants access to admins, managers and sponsors of the antenne" do
        is_expected.to permit(admin, stats_report)
        is_expected.to permit(manager, stats_report)
        is_expected.to permit(sponsor, stats_report)
        is_expected.not_to permit(other_user, stats_report)
      end
    end
  end
end
