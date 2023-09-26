require 'rails_helper'

RSpec.describe DiagnosisPolicy, type: :policy do
  let(:user) { nil }
  let(:diagnosis) { create :diagnosis }

  subject { described_class }

  permissions :show? do
    context "user is diagnosis advisor" do
      let(:user) { diagnosis.advisor }

      it { is_expected.not_to permit(user, diagnosis) }
    end

    context "advisor in the same antenne" do
      let(:user) { create :user, antenne: diagnosis.advisor.antenne }

      it { is_expected.not_to permit(user, diagnosis) }
    end

    context "expert in the same antenne" do
      let(:diagnosis) { create :diagnosis_completed }
      let(:user) { create :user, antenne: diagnosis.expert_antennes.first }

      it { is_expected.not_to permit(user, diagnosis) }
    end

    context "grants access if user is admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, diagnosis) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user, antenne: create(:antenne) }

      it { is_expected.not_to permit(user, diagnosis) }
    end
  end

  permissions :create? do
     context "grants access if user is admin" do
       let(:user) { create :user, :admin }

       it { is_expected.to permit(user, diagnosis) }
     end

     context "denies access if user is not admin" do
       let(:user) { create :user }

       it { is_expected.not_to permit(user, diagnosis) }
     end
   end

  permissions :update? do
     context "denies access if user is diagnosis advisor" do
        let(:user) { diagnosis.advisor }

        it { is_expected.not_to permit(user, diagnosis) }
      end

     context "grants access if user is admin" do
        let(:user) { create :user, :admin }

        it { is_expected.to permit(user, diagnosis) }
      end

     context "denies access if user is another user" do
        let(:user) { create :user, antenne: create(:antenne) }

        it { is_expected.not_to permit(user, diagnosis) }
      end
   end
end
