# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DiagnosesController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, content: Faker::Lorem.paragraph }

  describe 'GET #show' do
    it('returns http success') do
      get :show, format: :json, params: { id: diagnosis.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it('returns http success') do
      post :create, format: :json, params: { siret: '12345678901234' }

      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    subject(:request) { patch :update, format: :json, params: { id: diagnosis.id, diagnosis: { content: new_content } } }

    let(:new_content) { 'Lorem fake stuff content' }

    before { request }

    it('returns http success') { expect(response).to have_http_status(:success) }
    it('updates the diagnosis s content') { expect(diagnosis.reload.content).to eq(new_content) }
  end
end
