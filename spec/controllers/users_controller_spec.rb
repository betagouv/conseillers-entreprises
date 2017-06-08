# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  login_user

  describe 'GET #show' do
    it do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    it do
      patch :update, format: :json, params: { user: { email: current_user.email } }
      expect(response).to have_http_status(:success)
    end
  end
end
