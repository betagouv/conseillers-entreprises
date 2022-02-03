# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoftDeletable do
  describe 'For Users' do
    context 'user with personal_skillsets' do
      # Utilisateur avec un seul expert du même nom OK
      let(:user) { create :user }
      let!(:expert) { user.personal_skillsets.first }

      before { user.destroy }

      it 'Soft delete the user and his expert' do
        expect(user.deleted?).to eq true
        expect(expert.reload.deleted?).to eq true
      end
    end

    context 'User with many experts' do
      # Utilisateur avec plusieurs experts
      let!(:user_1) { create :user }
      let!(:user_2) { create :user }
      let!(:user_3) { create :user }
      # Expert avec d'autres utilisateurs KO
      let!(:expert_1) { create :expert, users: [user_1, user_2, user_3] }

      before { user_1.destroy }

      it "Soft delete only user expert with one user" do
        expect(user_1.deleted?).to eq true
        expect(user_2.reload.deleted?).to eq false
        expect(user_3.reload.deleted?).to eq false
        expect(expert_1.reload.users).to match_array [user_2, user_3]
        expect(expert_1.reload.deleted?).to eq false
      end
    end
  end

  describe 'For Experts' do
    context 'with personal_skillsets' do
      let(:user) { create :user }
      # Expert avec un utilisateur du même nom OK
      let!(:expert) { user.personal_skillsets.first }

      before { expert.destroy }

      it 'Soft delete the expert and his personal user' do
        expect(expert.deleted?).to eq true
        expect(user.reload.deleted?).to eq true
      end
    end

    context 'With some users' do
      let(:user_1) { create :user }
      let(:user_2) { create :user }
      # Expert qui a plusieurs utilisateurs qui on eux même que cet expert OK
      let(:expert) { create :expert, users: [user_1, user_2] }

      before { expert.destroy }

      it 'Soft delete the expert and his users' do
        expect(expert.deleted?).to eq true
        expect(user_1.reload.deleted?).to eq true
        expect(user_2.reload.deleted?).to eq true
      end
    end

    context 'With some users and personal skillsets' do
      let(:user_1) { create :user }
      let!(:expert_1) { user_1.personal_skillsets.first }
      let(:user_2) { create :user }
      let!(:expert_2) { user_2.personal_skillsets.first }
      # Expert qui a plusieurs utilisateurs qui on eux même que cet expert OK
      let(:expert) { create :expert, users: [user_1, user_2] }

      before { expert.destroy }

      it 'Soft delete the expert and his users' do
        expect(expert.deleted?).to eq true
        expect(user_1.reload.deleted?).to eq true
        expect(expert_1.reload.deleted?).to eq true
        expect(user_2.reload.deleted?).to eq true
        expect(expert_2.reload.deleted?).to eq true
      end
    end

    context 'With users with many experts' do
      # Utilisateur avec plusieurs experts KO
      let(:user) { create :user }
      let(:another_user) { create :user }
      # Expert que l'on supprime OK
      let!(:expert) { create :expert, users: [user] }
      # Autre Expert avec plusieurs utilisateurs KO
      let!(:expert_2) { create :expert, users: [user, another_user] }

      before { expert.destroy }

      it 'Soft delete only expert' do
        expect(expert.deleted?).to eq true
        expect(expert_2.reload.deleted?).to eq false
        expect(user.reload.deleted?).to eq false
      end
    end
  end

  describe 'For Antennes' do
    before { antenne.destroy }

    context 'with experts and advisors' do
      let(:antenne) { create :antenne, advisors: [user_1, user_2], experts: [expert, expert_2] }
      let(:user_1) { create :user }
      let(:user_2) { create :user }
      let!(:expert) { create :expert, users: [user_1] }
      let!(:expert_2) { create :expert, users: [user_1, user_2] }

      context 'with active experts and advisors' do
        it 'Don’t delete antenne' do
          expect(antenne.deleted?).to eq false
          expect(expert.reload.deleted?).to eq false
          expect(expert_2.reload.deleted?).to eq false
          expect(user_1.reload.deleted?).to eq false
          expect(user_2.reload.deleted?).to eq false
        end
      end

      context 'with deleted experts and advisors' do
        before do
          user_1.destroy
          user_2.destroy
          antenne.destroy
        end

        it 'Delete antenne' do
          expect(antenne.deleted?).to eq true
        end
      end
    end

    context 'without experts or advisors' do
      let(:antenne) { create :antenne }

      it 'Delete antenne' do
        expect(antenne.deleted?).to eq true
      end
    end
  end

  describe 'For Institutions' do
    let(:institution) { create :institution, antennes: [antenne] }
    let(:antenne) { create :antenne, advisors: [user], experts: [expert] }
    let(:user) { create :user }
    let(:expert) { create :expert }

    before { institution.destroy }

    it 'Soft delete antennes, users and experts' do
      expect(institution.deleted?).to eq true
      expect(antenne.reload.deleted?).to eq true
      expect(expert.reload.deleted?).to eq true
      expect(user.reload.deleted?).to eq true
    end
  end
end
