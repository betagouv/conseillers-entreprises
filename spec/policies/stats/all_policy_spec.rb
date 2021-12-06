require 'rails_helper'

RSpec.describe Stats::AllPolicy, type: :policy do
  let(:no_user) { nil }
  let(:user) { create :user }
  let(:admin) { create :user, role: 'admin' }

  subject { described_class }

  permissions :team? do
    context "grants access to admin" do
      it { is_expected.to permit(admin, Stats::All) }
    end

    context "denies access to no admin user" do
      it { is_expected.not_to permit(user, Stats::All) }
      it { is_expected.not_to permit(no_user, Stats::All) }
    end
  end
end
