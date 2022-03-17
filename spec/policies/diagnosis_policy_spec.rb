require 'rails_helper'

RSpec.describe DiagnosisPolicy, type: :policy do
  let(:user) { nil }
  let(:diagnosis) { create :diagnosis }

  subject { described_class }

  permissions :index? do
    context "user is can_view_diagnoses_tab" do
      let(:user) { create :user, can_view_diagnoses_tab: true }

      it { is_expected.to permit(user, Diagnosis) }
    end

    context "denies access has not can_view_diagnoses_tab" do
      let(:user) { create :user, can_view_diagnoses_tab: false }

      it { is_expected.not_to permit(user, Diagnosis) }
    end
  end

  permissions :show? do
    context "user is diagnosis advisor" do
      let(:user) { diagnosis.advisor }

      it { is_expected.to permit(user, diagnosis) }
    end

    context "advisor in the same antenne" do
      let(:user) { create :user, antenne: diagnosis.advisor.antenne }

      it { is_expected.to permit(user, diagnosis) }
    end

    context "expert in the same antenne" do
      let(:diagnosis) { create :diagnosis_completed }
      let(:user) { create :user, antenne: diagnosis.expert_antennes.first }

      it { is_expected.to permit(user, diagnosis) }
    end

    context "grants access if user is admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, diagnosis) }
    end

    context "grants access if user is support" do
      let(:user) { create :user, experts: [expert] }
      let(:expert) { create :expert, communes: [diagnosis.facility.commune] }
      let(:support_subject) { create :subject, is_support: true }
      let!(:expert_subject) { create :expert_subject, expert: expert, institution_subject: institution_subject }
      let(:institution_subject) { create :institution_subject, subject: support_subject }

      it { is_expected.to permit(user, diagnosis) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user, antenne: create(:antenne) }

      it { is_expected.not_to permit(user, diagnosis) }
    end

    context "denies access if user is another support_user" do
      let(:user) { create :user, antenne: create(:antenne) }
      let(:another_expert) { create :expert, users: [user] }
      let!(:expert_subject2) { create :expert_subject, expert: another_expert, institution_subject: institution_subject }
      let(:institution_subject) { create :institution_subject, subject: support_subject }
      let(:support_subject) { create :subject, is_support: true }

      it { is_expected.not_to permit(user, diagnosis) }
    end
  end

  permissions :create? do
     context "all user can create a diagnosis" do
        let(:user) { create :user }

        it { is_expected.to permit(user, diagnosis) }
      end
   end

  permissions :update? do
     context "grants access if user is diagnosis advisor" do
        let(:user) { diagnosis.advisor }

        it { is_expected.to permit(user, diagnosis) }
      end

     context "grants access if user is admin" do
        let(:user) { create :user, :admin }

        it { is_expected.to permit(user, diagnosis) }
      end

     context "grants access if user is support" do
        let(:user) { create :user, experts: [expert] }
        let(:expert) { create :expert, communes: [diagnosis.facility.commune] }
        let(:support_subject) { create :subject, is_support: true }
        let!(:expert_subject) { create :expert_subject, expert: expert, institution_subject: institution_subject }
        let(:institution_subject) { create :institution_subject, subject: support_subject }

        it { is_expected.to permit(user, diagnosis) }
      end

     context "denies access if user is another user" do
        let(:user) { create :user, antenne: create(:antenne) }

        it { is_expected.not_to permit(user, diagnosis) }
      end

     context "denies access if user is another support_user" do
        let(:user) { create :user, antenne: create(:antenne) }
        let(:another_expert) { create :expert, users: [user] }
        let!(:expert_subject2) { create :expert_subject, expert: another_expert, institution_subject: institution_subject }
        let(:institution_subject) { create :institution_subject, subject: support_subject }
        let(:support_subject) { create :subject, is_support: true }

        it { is_expected.not_to permit(user, diagnosis) }
      end
   end

  permissions :destroy? do
     context "denie access if user is diagnosis advisor" do
        let(:user) { diagnosis.advisor }

        it { is_expected.not_to permit(user, diagnosis) }
      end

     context "grants access if user is admin" do
        let(:user) { create :user, :admin }

        it { is_expected.to permit(user, diagnosis) }
      end

     context "denies access if user is support" do
        let(:user) { create :user, experts: [expert] }
        let(:expert) { create :expert, communes: [diagnosis.facility.commune] }
        let(:support_subject) { create :subject, is_support: true }
        let!(:expert_subject) { create :expert_subject, expert: expert, institution_subject: institution_subject }
        let(:institution_subject) { create :institution_subject, subject: support_subject }

        it { is_expected.not_to permit(user, diagnosis) }
      end

     context "denies access if user is another user" do
        let(:user) { create :user, antenne: create(:antenne) }

        it { is_expected.not_to permit(user, diagnosis) }
      end
   end
end
