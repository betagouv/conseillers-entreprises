# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::UsersController, type: :controller do
  login_admin

  describe 'GET #index' do
    let(:institution_1) { create :institution }
    let(:subject_1) { create :subject }
    let!(:institution_subject) { create :institution_subject, institution: institution_1, subject: subject_1 }
    let!(:antenne_1) { create :antenne, communes: [commune_ouest], institution: institution_1 }
    let!(:expert_subject_1) { create :expert_subject, institution_subject: institution_subject, expert: expert_1 }
    let!(:expert_1) { create :expert, users: [user_1], antenne: antenne_1 }
    let!(:user_1) { create :user, :invitation_accepted, antenne: antenne_1 }
    let!(:antenne_2) { create :antenne, communes: [commune_est], institution: institution_1 }
    let!(:expert_subject_2) { create :expert_subject, institution_subject: institution_subject, expert: expert_2 }
    let!(:expert_2) { create :expert, users: [user_2], antenne: antenne_2 }
    let!(:user_2) { create :user, :invitation_accepted, antenne: antenne_2 }
    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    context 'without region params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug } }

      it 'return all users for the institution' do
        request
        expect(assigns(:users)).to match_array([user_1, user_2])
      end
    end

    # Pending due to PSQL error
    context 'with region params' do
      subject(:request) { get :index, params: { institution_slug: institution_1.slug, region_id: region_ouest.id } }
      # Utilisateur dans la région OK (user_1)
      # Utilisateur en dehors de la région KO (user_2)

      it 'return users for the selected region' do
        request
        # Search Users due to 'relevant_for_skills' scope which return duplicate rows for users
        user = assigns(:users).find_by(email: user_1.email)
        expect(assigns(:users)).to match_array([user])
      end
    end
  end

  describe '#POST send_invitations' do
    let(:institution) { create :institution }
    let!(:antenne) { create :antenne, institution: institution }
    let!(:user) { create :user, antenne: antenne, invitation_sent_at: nil }

    subject(:request) { post :send_invitations, params: { institution_slug: institution.slug, users_ids: "#{user.id}" } }

    before { request }

    it 'expect invitation sent to user' do
      expect(user.reload.invitation_sent_at).not_to be nil
    end
  end
end
