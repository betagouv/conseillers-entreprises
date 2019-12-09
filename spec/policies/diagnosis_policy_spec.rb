require 'rails_helper'

RSpec.describe DiagnosisPolicy, type: :policy do
  let(:user) { create :user }
  let(:diagnosis) { create :diagnosis, advisor: user }
  let(:admin) { create :user, is_admin: true }
  let(:another_user) { create :user, antenne: create(:antenne) }
  let(:user_same_antenne) { create :user, antenne: user.antenne }

  let(:support_subject) { create :subject, is_support: true }
  let(:institution_subject) { create :institution_subject, subject: support_subject }
  let(:expert) { create :expert, communes: [diagnosis2.facility.commune] }
  let(:support_user) { create :user, experts: [expert] }
  let!(:expert_subject) { create :expert_subject, expert: expert, institution_subject: institution_subject }
  let(:diagnosis2) { create :diagnosis }

  let(:another_support_user) { create :user, antenne: create(:antenne) }
  let(:another_expert) { create :expert, users: [another_support_user] }
  let!(:expert_subject2) { create :expert_subject, expert: another_expert, institution_subject: institution_subject }

  subject { described_class }

  permissions :show? do
    it "grants access if user is diagnosis advisor" do
      expect(subject).to permit(user, diagnosis)
    end
    it "grants access if user in the same antenne" do
      expect(subject).to permit(user_same_antenne, diagnosis)
    end
    it "grants access if user is admin" do
      expect(subject).to permit(admin, diagnosis)
    end
    it "grants access if user is support" do
      expect(subject).to permit(support_user, diagnosis2)
    end
    it "denies access if user is another user" do
      expect(subject).not_to permit(another_user, diagnosis)
    end
    it "denies access if user is another support_user" do
      expect(subject).not_to permit(another_support_user, diagnosis)
    end
  end

  permissions :create? do
    it "all user can create a diagnosis" do
      expect(subject).to permit(user, diagnosis)
    end
  end

  permissions :update? do
    it "grants access if user is diagnosis advisor" do
      expect(subject).to permit(user, diagnosis)
    end
    it "grants access if user is admin" do
      expect(subject).to permit(admin, diagnosis)
    end
    it "grants access if user is support" do
      expect(subject).to permit(support_user, diagnosis2)
    end
    it "denies access if user is another user" do
      expect(subject).not_to permit(another_user, diagnosis)
    end
    it "denies access if user is another support_user" do
      expect(subject).not_to permit(another_support_user, diagnosis)
    end
  end

  permissions :destroy? do
    it "denies access if user is diagnosis advisor" do
      expect(subject).not_to permit(user, diagnosis)
    end
    it "grants access if user is admin" do
      expect(subject).to permit(admin, diagnosis)
    end
    it "denies access if user is support" do
      expect(subject).not_to permit(support_user, diagnosis2)
    end
    it "denies access if user is another user" do
      expect(subject).not_to permit(another_user, diagnosis)
    end
  end
end
