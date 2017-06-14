# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  login_user

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      siret = '12345678901234'
      get :new, params: { visit: { siret: siret } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'save worked' do
      it 'redirects to the show page' do
        siret = '12345678901234'
        post :create, params: { visit: { siret: siret, happened_at: 1.day.from_now } }
        is_expected.to redirect_to company_path(siret)
      end
    end

    context 'saved failed' do
      it 'does not redirect' do
        post :create, params: { visit: { happened_at: 1.day.from_now } }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #edit_visitee' do
    it 'returns http success' do
      visit = create :visit
      get :edit_visitee, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update_visitee' do
    subject { patch :update_visitee, params: { id: visit.id, visit: { visitee_attributes: visitee_attributes } } }

    let(:visit) { create :visit }
    let(:user) { build :user }

    context 'save worked' do
      let(:visitee_attributes) do
        {
          first_name: user.first_name, last_name: user.last_name, email: user.email,
          role: user.role, institution: user.institution, phone_number: user.phone_number
        }
      end

      it 'redirects to the show page' do
        is_expected.to redirect_to root_path
      end
    end

    context 'saved failed' do
      let(:visitee_attributes) { { first_name: user.first_name, last_name: user.last_name } }

      it 'does not redirect' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #prepare_email' do
    it 'returns http success' do
      visit = create :visit
      get :prepare_email, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end
end
