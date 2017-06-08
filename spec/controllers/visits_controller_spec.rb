# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  login_user

  let(:siret) { '12345678901234' }

  describe 'GET #new' do
    it 'returns http success' do
      get :new, params: { visit: { siret: siret } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'save worked' do
      it 'redirects to the show page' do
        post :create, params: { visit: { siret: siret, happened_at: 1.day.from_now } }
        is_expected.to redirect_to company_path(siret)
      end
    end

    context 'saved failed' do
      it 'redirects to the show page' do
        post :create, params: { visit: { happened_at: 1.day.from_now } }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
