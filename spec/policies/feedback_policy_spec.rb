require 'rails_helper'

RSpec.describe FeedbackPolicy, type: :policy do
  let(:user) { nil }
  let(:diagnosis) { create :diagnosis }

  subject { described_class }

  permissions :destroy? do
    context "grants access if user is feedback creator" do
      let(:feedback) { create :feedback, user: user }
      let(:user) { diagnosis.advisor }

      it { expect(subject).to permit(user, feedback) }
    end
    context "grants access if user is admin" do
      let(:feedback) { create :feedback, :of_user }
      let(:user) { create :user, is_admin: true }

      it { expect(subject).to permit(user, feedback) }
    end
    context "denies access if user is another user" do
      let(:feedback) { create :feedback, :of_user }
      let(:user) { create :user }

      it { expect(subject).not_to permit(user, feedback) }
    end
  end
end
