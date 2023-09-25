require 'rails_helper'

RSpec.describe Manager::StatsController do

  login_manager

  describe 'GET #index' do
    subject(:request) { get :index }

    before { request }

    it 'returns http success' do
      expect(request).to be_successful
      expect(assigns(:stats)).not_to be_nil
    end
  end
end
