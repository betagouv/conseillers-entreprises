# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerritoryUsersController, type: :controller do
  login_user

  describe 'GET #diagnosis' do
    subject(:request) { get :diagnosis, params: { diagnosis_id: diagnosis.id } }

    let(:diagnosis) { create :diagnosis, visit: visit }
    let(:visit) { create :visit, facility: facility }
    let(:facility) { create :facility }

    context 'current user is not territory user' do
      it('raises error') { expect { request }.to raise_error ActionController::RoutingError }
    end

    context 'current user is a territory user' do
      let!(:territory_user) { create :territory_user, user: current_user }

      context 'user is not responsible of diagnosis territory' do
        it('raises error') { expect { request }.to raise_error ActionController::RoutingError }
      end

      context 'user is responsible of diagnosis territory' do
        before do
          create :territory_city, territory: territory_user.territory, city_code: facility.city_code

          request
        end

        it('returns http success') { expect(response).to have_http_status(:success) }
      end
    end
  end
end
