require 'rails_helper'

RSpec.describe NeedPolicy, type: :policy do
  let(:user) { nil }
  let!(:need) { create :need_with_matches }

  subject { described_class }

  permissions :show? do
    context "user is diagnosis advisor" do
      let(:user) { need.advisor }

      it { is_expected.to permit(user, need) }
    end

    context "advisor in the same antenne" do
      let(:user) { create :user, antenne: need.advisor_antenne }

      it { is_expected.to permit(user, need) }
    end

    context "user belongs to need experts" do
      let(:user) { create :user, experts: [need.experts.first] }

      it { is_expected.to permit(user, need) }
    end

    context "expert in the same antenne" do
      let(:user) { create :user, antenne: need.expert_antennes.first }

      it { is_expected.to permit(user, need) }
    end

    context "grants access if user is admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to permit(user, need) }
    end

    context "grants access if user is support" do
      let(:user) { create :user, experts: [expert] }
      let(:expert) { create :expert, communes: [need.diagnosis.facility.commune] }
      let(:support_subject) { create :subject, is_support: true }
      let!(:expert_subject) { create :expert_subject, expert: expert, institution_subject: institution_subject }
      let(:institution_subject) { create :institution_subject, subject: support_subject }

      it { is_expected.to permit(user, need) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user, antenne: create(:antenne) }

      it { is_expected.not_to permit(user, need) }
    end

    context "denies access if user is another support_user" do
      let(:user) { create :user, antenne: create(:antenne) }
      let(:another_expert) { create :expert, users: [user] }
      let!(:expert_subject2) { create :expert_subject, expert: another_expert, institution_subject: institution_subject }
      let(:institution_subject) { create :institution_subject, subject: support_subject }
      let(:support_subject) { create :subject, is_support: true }

      it { is_expected.not_to permit(user, need) }
    end
  end

  permissions :show_need_actions? do
    context "user belongs to need experts" do
      let(:user) { create :user, experts: [need.experts.first] }

      it { is_expected.to permit(user, need) }
    end

    context "user in the same antenne" do
      let(:user) { create :user, antenne: need.experts.first.antenne }

      it { is_expected.not_to permit(user, need) }
    end

    context "denies access if user is admin" do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user, need) }
    end

    context "denies access if user is another user" do
      let(:user) { create :user, antenne: create(:antenne) }

      it { is_expected.not_to permit(user, need) }
    end
  end

  describe 'Scopes' do
    let!(:other_need) { create :need_with_matches }
    let(:need_scope) { NeedPolicy::Scope.new(user, Need.all).resolve }

    context 'admin user' do
      let(:user) { create :user, :admin }

      it 'allows access to all needs' do
        expect(need_scope.to_a).to match_array([need, other_need])
      end
    end

    context 'expert user' do
      let(:user) { need.contacted_users.first }

      it 'allows a limited subset of needs' do
        expect(need_scope.to_a).to match_array([need])
      end
    end
  end
end
