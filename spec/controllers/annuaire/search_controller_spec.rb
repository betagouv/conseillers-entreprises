# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::SearchController do
  login_admin

  describe 'POST #search' do
    let(:institution) { create :institution }
    let(:antenne) { create :antenne, institution: institution }
    let(:user) { create :user, antenne: antenne }

    context 'when the query is a user' do
      it 'redirects to the user in this antenne' do
        post :search, params: { query: "User-#{user.id}" }
        expect(response).to redirect_to(institution_users_path(institution.slug, antenne_id: antenne.id, advisor: user))
      end
    end

    context 'when the query is an antenne' do
      it 'redirects to the antenne users view' do
        post :search, params: { query: "Antenne-#{antenne.id}" }
        expect(response).to redirect_to(institution_users_path(institution.slug, antenne_id: antenne.id))
      end
    end

    context 'when the query is an institution' do
      it 'redirects to the institution users view' do
        post :search, params: { query: "Institution-#{institution.id}" }
        expect(response).to redirect_to(institution_users_path(institution.slug))
      end
    end

    context 'when the query is not a user, antenne, or institution and current page is an institution page' do
      it 'redirects to the institutions index' do
        post :search, params: { query: 'invalid', institution_slug: institution.slug }
        expect(response).to redirect_to(institution_users_path(institution.slug))
      end
    end

    context 'when the query is not a user, antenne, or institution' do
      it 'redirects to the institutions index' do
        post :search, params: { query: 'invalid' }
        expect(response).to redirect_to(institutions_path)
      end
    end
  end
end
