# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::SearchController do
  login_admin

  describe 'POST #search' do
    let(:institution_1) { create :institution }
    let!(:antenne_1) { create :antenne, institution: institution_1 }
    let!(:user_1) { create :user, :invitation_accepted, full_name: 'Marie Dupont', antenne: antenne_1 }

    context 'the query is a user' do
      it 'redirect to user in this antenne' do
        post :search, params: { query: "User-#{user_1.id}" }
        expect(response).to redirect_to(institution_users_path(institution_1.slug, { advisor: user_1, antenne_id: user_1.antenne }))
      end
    end

    context 'the query is an antenne' do
      it 'redirect to the antenne view' do
        post :search, params: { query: "Antenne-#{antenne_1.id}" }
        expect(response).to redirect_to(institution_users_path(antenne_1.institution.slug, antenne_id: antenne_1))
      end
    end

    context 'the query is an institution' do
      it 'redirect to the antenne view' do
        post :search, params: { query: "Institution-#{institution_1.id}" }
        expect(response).to redirect_to(institution_users_path(institution_1.slug))
      end
    end

    context 'the query is blank and there is a selected region' do
      it 'redirect to institutions index' do
        post :search, params: { query: '', region_id: 1 }
        expect(response).to redirect_to(institutions_path(region_id: 1))
      end
    end

    context 'No results' do
      it 'redirect_back' do
        post :search, params: { query: 'aze' }
        expect(response).to redirect_to(institutions_path)
      end
    end
  end
end
