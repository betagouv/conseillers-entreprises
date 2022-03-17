require 'rails_helper'

RSpec.describe ContactPolicy, type: :policy do
  let(:contact) { create :contact }
  let(:solicitation) { create :solicitation, email: contact.email }

  subject { described_class }

  permissions :show_needs_history? do
    context 'user is admin' do
      let(:user) { create :user, role: 'admin' }

      describe "grants access if there is any completed need for a contact" do
        let!(:diagnosis) { create :diagnosis_completed, visitee: contact, solicitation: solicitation }
        let!(:another_diagnosis) { create :diagnosis_completed,  visitee: contact }

        it { is_expected.to permit(user, contact) }
      end

      describe "denies access if there is no completed need for a contact" do
        let!(:diagnosis) { create :diagnosis, visitee: contact, solicitation: solicitation }

        it { is_expected.not_to permit(user, contact) }
      end
    end

    context 'User is not admin' do
      let(:user) { create :user }
      let(:expert) { user.experts.first }
      let(:diagnosis) { create :diagnosis, visitee: contact, solicitation: solicitation }
      let(:need) { create :need_with_matches, diagnosis: diagnosis, status: :quo }

      describe "grants access if user is in user.received_needs and there is any need for a contact" do
        let!(:a_match) { create :match, need: need, expert: expert, status: :quo }

        it { is_expected.to permit(user, contact) }
      end

      describe "denies access if user is not in user.received_needs and their is many needs for a contact" do
        let!(:a_match) { create :match, need: need, status: :quo }

        it { is_expected.not_to permit(user, contact) }
      end
    end
  end
end
