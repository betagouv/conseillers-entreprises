# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  login_user

  describe 'GET #show' do
    it do
      get :show
      expect(response).to be_successful
    end
  end
end
