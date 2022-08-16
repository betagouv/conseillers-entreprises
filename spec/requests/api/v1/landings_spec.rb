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
      let!(:landing_01) { create(:landing, title: 'Landing 01', institution: institution) }

      it 'returns success' do
        get "/api/v1/landings", headers: authentication_headers(institution)
        json = JSON.parse(response.body)

        expect(json).to eq([
          {
            "id" => landing_01.id,
                    "iframe_category" => "integral",
                    "partner_url" => nil,
                    "slug" => landing_01.slug,
                    "title" => 'Landing 01'
          }
        ])
      end
    end
  end
end
