require 'rails_helper'

RSpec.describe Api::Internal::CommunesController do
  describe 'GET #search' do
    it 'returns a successful JSON array response' do
      get :search, params: { q: 'Paris' }

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to be_an(Array)
    end

    it 'returns an empty array for a blank query' do
      get :search, params: { q: '' }

      expect(response).to have_http_status(:success)
      data = response.parsed_body.is_a?(Hash) ? response.parsed_body['data'] : response.parsed_body
      expect(data).to eq([])
    end
  end
end
