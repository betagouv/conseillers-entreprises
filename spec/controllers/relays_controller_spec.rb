# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelaysController, type: :controller do
  login_user

  describe 'GET #index' do
    let(:diagnosis) { create :diagnosis }

    before { get :index }

    context 'current user is not relay' do
      it { expect(response).to be_successful }
    end

    context 'current user is a relay' do
      before { create :relay, user: current_user }

      it { expect(response).to be_successful }
    end
  end

  describe 'GET #diagnosis' do
    subject(:request) { get :diagnosis, params: { diagnosis_id: diagnosis.id } }

    let(:diagnosis) { create :diagnosis, visit: visit }
    let(:visit) { create :visit, facility: facility }
    let(:facility) { create :facility }

    context 'current user is not relay' do
      it('raises error') { expect { request }.to raise_error ActionController::RoutingError }
    end

    context 'current user is a relay' do
      let!(:relay) { create :relay, user: current_user }

      context 'user is not responsible of diagnosis territory' do
        it('raises error') { expect { request }.to raise_error ActionController::RoutingError }
      end

      context 'user is responsible of diagnosis territory' do
        before do
          create :territory_city, territory: relay.territory, city_code: facility.city_code
          request
        end

        it('returns http success') { expect(response).to be_successful }
      end

      context 'safe deleted diagnosis' do
        before do
          diagnosis.archive!

          create :territory_city, territory: relay.territory, city_code: facility.city_code
          request
        end

        it('returns http success') { expect(response).to be_successful }
      end
    end
  end
end
