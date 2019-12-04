require 'rails_helper'

RSpec.describe FeedbackPolicy, type: :policy do
  let(:user) { create :user }
  let(:expert) { create :expert, users: [user] }
  let(:user_feedback) { create :feedback, :of_user, user: user }
  let(:expert_feedback) { create :feedback, :of_expert, expert: expert }
  let(:admin) { create :user, is_admin: true }
  let(:another_user) { create :user }

  subject { described_class }

  permissions :destroy? do
    it "grants access if expert is feedback creator" do
      expect(subject).to permit(user, expert_feedback)
    end
    it "grants access if user is feedback creator" do
      expect(subject).to permit(user, user_feedback)
    end
    it "grants access if user is admin" do
      expect(subject).to permit(admin, user_feedback)
    end
    it "denies access if user is another user" do
      expect(subject).not_to permit(another_user, user_feedback)
    end
  end
end
