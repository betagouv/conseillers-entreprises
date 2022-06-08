# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::SearchController, type: :controller do
  login_admin

  describe 'POST #search' do
    let(:institution_1) { create :institution }
    let(:subject_1) { create :subject }
    let!(:institution_subject) { create :institution_subject, institution: institution_1, subject: subject_1 }
    let!(:antenne_1) { create :antenne, institution: institution_1 }
    let!(:expert_subject_1) { create :expert_subject, institution_subject: institution_subject, expert: expert_1 }
    let!(:expert_1) { create :expert, users: [user_1], antenne: antenne_1 }
    let!(:user_1) { create :user, :invitation_accepted, full_name: 'Marie Dupont', antenne: antenne_1 }
    let!(:user_2) { create :user, :invitation_accepted, antenne: antenne_1 }
    let!(:antenne_2) { create :antenne, institution: institution_1 }
    let!(:expert_subject_2) { create :expert_subject, institution_subject: institution_subject, expert: expert_2 }
    let!(:expert_2) { create :expert, users: [user_3], antenne: antenne_2 }
    let!(:user_3) { create :user, :invitation_accepted, full_name: 'Jean Dupont', antenne: antenne_2 }

    context 'with one user found' do
      it 'redirect to user in this antenne' do
        post :search, params: { by_institution: institution_1.slug, by_name: user_1.full_name }
        expect(response).to redirect_to(institution_users_path(institution_1.slug, { advisor: user_1, antenne_id: user_1.antenne, by_institution: institution_1.slug, by_name: user_1.full_name }))
      end
    end

    context 'If there is a parameter for search by name and multiple users' do
      it 'redirects to the choice page with the list of users found' do
        post :search, params: { by_institution: institution_1.slug, by_name: 'Dupont' }
        expect(response).to redirect_to(annuaire_many_users_path(advisors: [user_1.id, user_3.id], by_institution: institution_1.slug, by_name: 'Dupont'))
        # //?5375&advisors%5B%5D=5377&by_institution=clement-et-pelletier2&by_name=Dupont"
        # //?5375&advisors%5B%5D=5376&by_institution=clement-et-pelletier2&by_name=Dupont"
      end
    end

    context 'search by antennes and not by name' do
      it 'redirects to antenne users' do
        post :search, params: { by_institution: institution_1.slug, by_antenne: antenne_1.id, by_name: '' }
        expect(response).to redirect_to(institution_users_path(institution_1.slug, { antenne_id: antenne_1.id, by_institution: institution_1.slug, by_antenne: antenne_1.id, by_name: '' }))
      end
    end

    context 'search by institution' do
      it 'redirects to institution users' do
        post :search, params: { by_institution: institution_1.slug, by_name: '' }
        expect(response).to redirect_to(institution_users_path(institution_1.slug, { by_institution: institution_1.slug, by_name: '' }))
      end
    end

    context 'No results' do
      it 'redirects to no results page' do
        post :search, params: { by_institution: institution_1.slug, by_antenne: '', by_name: 'Toto' }
        expect(response).to redirect_to(annuaire_no_user_path(by_antenne: '', by_institution: institution_1.slug, by_name: 'Toto'))
      end
    end
  end
end
