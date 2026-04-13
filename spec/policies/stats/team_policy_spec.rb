require 'rails_helper'

RSpec.describe Stats::TeamPolicy, type: :policy do
  let(:no_user) { nil }
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:sponsor) { create :user, :sponsor }

  subject { described_class }

  permissions :index? do
    context "grants access to admin and sponsor" do
      it { is_expected.to permit(admin, [:stats, :team]) }
      it { is_expected.to permit(sponsor, [:stats, :team]) }
    end

    context "denies access to no admin user" do
      it { is_expected.not_to permit(user, [:stats, :team]) }
      it { is_expected.not_to permit(no_user, [:stats, :team]) }
    end
  end
end
