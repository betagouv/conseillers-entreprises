# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoftDeletable do
  describe 'For Users' do
    context 'destroy (soft_delete)' do
      context 'user with single_user_experts' do
        # Utilisateur avec un seul expert du même nom KO
        let(:user) { create :user }
        let!(:expert) { create :expert, users: [user] }

        before { user.destroy }

        it 'Soft delete the user and his expert' do
          expect(user.deleted?).to be true
          expect(expert.reload.deleted?).to be false
        end
      end

      context 'User with many experts' do
        # Utilisateur avec plusieurs experts
        let!(:user_1) { create :user }
        let!(:expert_1) { create :expert, users: [user_1] }
        let!(:user_2) { create :user }
        let!(:expert_2) { create :expert, users: [user_2]}
        let!(:user_3) { create :user }
        # Expert avec d'autres utilisateurs KO
        let!(:team_1) { create :expert, users: [user_1, user_2, user_3] }

        before { user_1.destroy }

        it "Soft delete only user expert with one user" do
          expect(user_1.deleted?).to be true
          expect(user_2.reload.deleted?).to be false
          expect(expert_2.reload.deleted?).to be false
          expect(team_1.reload.users).to contain_exactly(user_2, user_3)
          expect(team_1.reload.deleted?).to be false
        end
      end
    end
  end

  describe 'For Experts' do
    context 'destroy (soft_delete)' do
      context 'with single_user_experts' do
        let(:user) { create :user }
        let(:expert) { create :expert, users: [user] }

        before { expert.destroy }

        it 'Soft delete the expert but not the user' do
          expect(expert.deleted?).to be true
          expect(user.reload.deleted?).to be false
        end
      end

      context 'With some users and single_user_experts' do
        let(:user_1) { create :user }
        let!(:expert_1) { create :expert, users: [user_1] }
        let(:user_2) { create :user }
        let!(:expert_2) { create :expert, users: [user_2] }
        # Expert qui a plusieurs utilisateurs qui on eux même que cet expert OK
        let(:team) { create :expert, users: [user_1, user_2] }

        before { team.destroy }

        it 'Soft deletes only the expert' do
          expect(team.deleted?).to be true
          expect(user_1.reload.deleted?).to be false
          expect(expert_1.reload.deleted?).to be false
          expect(user_2.reload.deleted?).to be false
          expect(expert_2.reload.deleted?).to be false
        end
      end

      context 'With users with many experts' do
        # Utilisateur avec plusieurs experts KO
        let(:user) { create :user }
        let(:another_user) { create :user }
        let!(:personal_skillset) { user.personal_skillsets.first }
        let!(:another_personal_skillset) { another_user.personal_skillsets.first }
        # Expert que l'on supprime OK
        let!(:expert) { create :expert, users: [user] }
        # Autre Expert avec plusieurs utilisateurs KO
        let!(:expert_2) { create :expert, users: [user, another_user] }

        before { expert.destroy }

        it 'Soft delete only expert' do
          expect(expert.deleted?).to be true
          expect(expert_2.reload.deleted?).to be false
          expect(user.reload.deleted?).to be false
          expect(personal_skillset.reload.deleted?).to be false
          expect(another_user.reload.deleted?).to be false
          expect(another_personal_skillset.reload.deleted?).to be false
        end
      end

      context 'Team with user in other teams' do
        let(:user_1) { create :user }
        let!(:single_user_expert_1) { create :expert, users: [user_1] }
        let(:user_2) { create :user }
        let!(:single_user_expert_2) { create :expert, users: [user_2] }
        let(:user_3) { create :user }
        let!(:single_user_expert_3) { create :expert, users: [user_3] }
        # Expert que l'on supprime OK
        let!(:team_1) { create :expert, users: [user_1, user_2] }
        # Autre Expert avec plusieurs utilisateurs KO
        let!(:team_2) { create :expert, users: [user_2, user_3] }

        before { team_1.destroy }

        it 'Soft delete only team_1' do
          expect(team_1.deleted?).to be true
          expect(user_1.reload.deleted?).to be false
          expect(user_2.reload.deleted?).to be false
          expect(team_2.reload.deleted?).to be false
          expect(user_3.reload.deleted?).to be false
          expect(single_user_expert_3.reload.deleted?).to be false
          expect(team_2.reload.users).to contain_exactly(user_2, user_3)
        end
      end
    end
  end

  describe 'For Antennes' do
    context 'destroy (soft_delete)' do
      context 'with experts and advisors' do
        let(:user_1) { create :user }
        let(:user_2) { create :user }
        let!(:expert) { create :expert, users: [user_1] }
        let!(:expert_2) { create :expert, users: [user_1, user_2] }
        let!(:antenne) { create :antenne, advisors: [user_1, user_2], experts: [expert, expert_2] }

        context 'with active experts and advisors' do
          before { antenne.destroy }

          it 'Don’t delete antenne' do
            expect(antenne.deleted?).to be false
            expect(expert.reload.deleted?).to be false
            expect(expert_2.reload.deleted?).to be false
            expect(user_1.reload.deleted?).to be false
            expect(user_2.reload.deleted?).to be false
          end
        end

        context 'with deleted experts and advisors' do
          before do
            antenne.destroy
          end

          it 'Delete antenne' do
            expect(antenne.deleted?).to be true
          end
        end
      end

      context 'without experts or advisors' do
        let(:antenne) { create :antenne }

        before { antenne.destroy }

        it 'Delete antenne' do
          expect(antenne.deleted?).to be true
        end
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
      expect(institution.deleted?).to be true
      expect(antenne.reload.deleted?).to be true
      expect(expert.reload.deleted?).to be true
      expect(user.reload.deleted?).to be true
    end
  end
end
