# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  login_user

  describe 'GET #show' do
    it 'returns http success' do
      visit = create :visit, advisor: current_user
      allow(UseCases::SearchFacility).to receive(:with_siret).with(visit.facility.siret)
      get :show, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end
end
