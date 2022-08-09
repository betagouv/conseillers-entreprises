require "rails_helper"

RSpec.describe "Authentication API", type: :request do

  describe "#index" do
    let!(:institution) { create(:institution) }

    context "when no landing" do
      it 'returns empty data' do
        get "/api/v1/landings", headers: authentication_headers(institution)
        json = JSON.parse(response.body)

        expect(json).to eq([])
      end
    end

    context "when has landings" do
      let!(:landing_01) { create(:landing, institution: institution) }

      it 'returns success' do
        get "/api/v1/landings", headers: authentication_headers(institution)
        json = JSON.parse(response.body)

        expect(json).to eq([landing_01.as_json])
      end
    end
  end
end