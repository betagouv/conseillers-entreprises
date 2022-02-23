require 'rails_helper'

RSpec.describe ReportPolicy, type: :policy do
  subject { described_class }

  permissions :index? do
    context "denies access if user is an admin" do
      let(:user) { create :user, role: 'admin' }

      it { is_expected.not_to permit(user) }
    end

    context "grants access if user is a region manager" do
      let(:user) { create :user, role: 'antenne_manager' }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end
  end

  permissions :download_matches? do
    let(:antenne) { create :antenne }
    let!(:quarterly_data) { create :quarterly_data, antenne: antenne }

    context "denies access if user is an admin" do
      let(:user) { create :user, role: 'admin' }

      it { is_expected.not_to permit(user, quarterly_data) }
    end

    context "grants access if user is a region manager for his antenne report" do
      let(:user) { create :user, role: 'antenne_manager', antenne: antenne }

      it { is_expected.to permit(user, quarterly_data) }
    end

    context "denies access if user is a region manager for another antenne report" do
      let(:user) { create :user, role: 'antenne_manager', antenne: create(:antenne) }

      it { is_expected.not_to permit(user, quarterly_data) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user, antenne: antenne }

      it { is_expected.not_to permit(user, quarterly_data) }
    end
  end
end
