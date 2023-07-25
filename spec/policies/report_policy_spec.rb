require 'rails_helper'

RSpec.describe ReportPolicy, type: :policy do
  subject { described_class }

  permissions :show_navbar? do
    context "denies access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user) }
    end

    context "grants access if user is a manager" do
      let(:user) { create :user, :manager }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end
  end

  permissions :index? do
    let(:antenne) { create :antenne }

    context "grant access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, antenne) }
    end

    context "grants access if antenne is in user managed antennes" do
      let(:user) { create :user, :manager, managed_antennes: [antenne] }

      it { is_expected.to permit(user, antenne) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user, antenne) }
    end
  end

  permissions :download? do
    let(:antenne) { create :antenne }
    let!(:quarterly_report) { create :quarterly_report, :category_matches, antenne: antenne }

    context "grant access if user is an admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, quarterly_report) }
    end

    context "grants access if user is a region manager for his antenne report" do
      let(:user) { create :user, :manager, antenne: antenne }

      it { is_expected.to permit(user, quarterly_report) }
    end

    context "denies access if user is a region manager for another antenne report" do
      let(:user) { create :user, :manager, antenne: create(:antenne) }

      it { is_expected.not_to permit(user, quarterly_report) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user, antenne: antenne }

      it { is_expected.not_to permit(user, quarterly_report) }
    end
  end
end
