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
end
