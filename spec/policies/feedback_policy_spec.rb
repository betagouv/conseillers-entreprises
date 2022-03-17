require 'rails_helper'

RSpec.describe FeedbackPolicy, type: :policy do
  let(:user) { nil }
  let(:diagnosis) { create :diagnosis }

  subject { described_class }

  permissions :destroy? do
    context "grants access if user is feedback creator" do
      let(:feedback) { create :feedback, :for_need, user: user }
      let(:user) { diagnosis.advisor }

      it { is_expected.to permit(user, feedback) }
    end

    context "denies access if user is admin" do
      let(:feedback) { create :feedback, :for_need }
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user, feedback) }
    end

    context "denies access if user is another user" do
      let(:feedback) { create :feedback, :for_need }
      let(:user) { create :user }

      it { is_expected.not_to permit(user, feedback) }
    end
  end
end
