# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::VisitsController, type: :controller do
  login_user

  describe 'GET #show' do
    subject(:request) { get :show, format: :json, params: { id: visit.id } }

    context 'when visit exists' do
      let(:visit) { create :visit, advisor: current_user }

      it 'returns http success' do
        request

        expect(response).to have_http_status(:success)
      end
    end

    context 'when visit does not exist' do
      let(:visit) { build :visit }

      it('raises an error') { expect { request }.to raise_error ActionController::UrlGenerationError }
    end
  end

  describe 'PATCH #update' do
    subject(:request) { patch :update, format: :json, params: { id: visit.id, visit: visit_params } }

    let(:visit) { create :visit, advisor: current_user }
    let(:visit_params) { { happened_on: date_string } }

    context 'when parameters are OK' do
      let(:date_string) { '2017-03-23' }

      before { request }

      it('returns http success') { expect(response).to have_http_status(:success) }
      it 'updates the visits date' do
        expect(visit.reload.happened_on).to eq DateTime.iso8601(date_string, Date::GREGORIAN)
      end
    end

    context 'when parameters are wrong' do
      let(:visit) { create :visit, advisor: current_user, happened_on: nil }
      let(:date_string) { 'Not an iso date string' }

      before do
        allow(controller).to receive(:send_error_notifications)
        request
      end

      it('returns http bad request') { expect(response).to have_http_status(:bad_request) }
      it('does not update the visits date') { expect(visit.reload.happened_on).to be_nil }
      it('sends an error notification') do
        expect(controller).to have_received(:send_error_notifications)
      end
    end
  end
end
