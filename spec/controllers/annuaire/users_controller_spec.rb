# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::UsersController, type: :controller do
  login_admin

  describe 'GET #search' do
    subject(:request) { get :search, params: { institution_slug: institution_1.slug, region_id: region_ouest.id } }

    let(:institution_1) { create :institution }
    let(:subject) { create :subject }
    let!(:institution_subject) { create :institution_subject, institution: institution_1, subject: subject }
    # Utilisateur dans la région OK
    let!(:antenne_1) { create :antenne, communes: [commune_ouest], institution: institution_1 }
    let!(:expert_subject_1) { create :expert_subject, institution_subject: institution_subject, expert: expert_1 }
    let!(:expert_1) { create :expert, users: [user_1], antenne: antenne_1 }
    let!(:user_1) { create :user, :invitation_accepted, antenne: antenne_1 }
    # Utilisateur en dehors de la région KO
    let!(:antenne_2) { create :antenne, communes: [commune_est], institution: institution_1 }
    let!(:expert_subject_2) { create :expert_subject, institution_subject: institution_subject, expert: expert_2 }
    let!(:expert_2) { create :expert, users: [user_2], antenne: antenne_2 }
    let!(:user_2) { create :user, :invitation_accepted, antenne: antenne_2 }

    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    it 'return users for the selected region' do
      request
      expect(assigns(:users)).to match_array([user_1])
    end
  end
end
