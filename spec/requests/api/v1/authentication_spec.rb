require "rails_helper"

RSpec.describe "Authentication API", type: :request do
  describe "when no token" do
    it 'returns error' do
      get "/api/v1/landings"

      expect(response).not_to be_successful
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "when wrong token" do
    it 'returns error' do
      get "/api/v1/landings", headers: { 'Authorization' => "Bearer token=daladirladada" }
      json = JSON.parse(response.body)

      expect(response).not_to be_successful
      expect(response).to have_http_status(:not_found)
      expect(json["errors"]).to eq([{"Token d’API"=>"n’existe pas ou est invalide"}])
    end
  end

  describe "when token without institution" do
    let(:token) { SecureRandom.hex(32) }

    before do
      ApiKey.create(token: token)
    end

    it 'returns error' do
      get "/api/v1/landings", headers: { 'Authorization' => "Bearer token=#{token}" }
      json = JSON.parse(response.body)

      expect(response).not_to be_successful
      expect(response).to have_http_status(:not_found)
      expect(json["errors"]).to eq([{"Token d’API"=>"n’existe pas ou est invalide"}])
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
