# frozen_string_literal: true

require 'rails_helper'

describe UnusedUsersService do
  let(:seven_months_ago) { Time.zone.now - 7.months }

  describe 'delete_users' do
    describe 'delete users and skillsets' do
      # Utilisateur invité depuis moins de 7 mois, invitation accepté ko
      let!(:user_1) { create :user, :invitation_accepted }
      # Utilisateur invité depuis moins de 7 mois, invitation non accepté ko
      let!(:user_2) { create :user, invitation_accepted_at: nil }
      # Utilisateur invité depuis plus de 7 mois, invitation accepté ko
      let!(:user_3) {
        create :user, :invitation_accepted, created_at: seven_months_ago,
               invitation_sent_at: seven_months_ago
      }
      # Utilisateur invité depuis plus de 7 mois, invitation non accepté ok
      let!(:user_4) {
        create :user, invitation_accepted_at: nil, created_at: seven_months_ago,
               invitation_sent_at: seven_months_ago, encrypted_password: ''
      }
      let!(:expert_4) { user_4.personal_skillsets.first }

      before { described_class.delete_users }

      it 'keep only active users' do
        expect(User.all).to match_array([user_1, user_2, user_3])
        expect(Expert.all).not_to include(expert_4)
      end
    end

    describe 'delete experts_subjects if needed' do
      let!(:user_1) {
        create :user, invitation_accepted_at: nil, created_at: seven_months_ago,
               invitation_sent_at: seven_months_ago, encrypted_password: ''
      }
      let!(:expert_1) { user_1.personal_skillsets.first }
      let!(:expert_subject) { create :expert_subject, expert: expert_1 }

      before { described_class.delete_users }

      it do
        expect(User.count).to eq 0
        expect(Expert.count).to eq 0
        expect(ExpertSubject.count).to eq 0
      end
    end

    describe 'don’t delete expert and users with matches' do
      let!(:user_1) {
        create :user, invitation_accepted_at: nil, created_at: seven_months_ago,
               invitation_sent_at: seven_months_ago, encrypted_password: ''
      }
      let!(:expert_1) { user_1.personal_skillsets.first }
      let!(:a_match) { create :match, expert: expert_1 }

      before do
        a_match.diagnosis.update(step: :completed)
        described_class.delete_users
      end

      it do
        expect(User.all).to include(user_1)
        expect(Expert.all).to include(expert_1)
      end
    end
  end
end
