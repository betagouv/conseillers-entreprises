require "rails_helper"

RSpec.describe "Authentication API", type: :request do

  describe "when no token" do
    it 'returns error' do
      get "/api/v1/landings"

      expect(response).not_to be_successful
      expect(response.status).to eq(401)
    end
  end

  describe "when wrong token" do
    it 'returns error' do
      get "/api/v1/landings", headers: { 'Authorization'=>"Bearer token=daladirladada" }

      expect(response).not_to be_successful
      expect(response.status).to eq(401)
    end
  end

  describe "when good token" do
    let!(:institution) { create(:institution) }

    it 'returns success' do
      get "/api/v1/landings", headers: authentication_headers(institution)
      expect(response).to be_successful
    end
  end
end