require "rails_helper"

RSpec.describe "llms.txt" do
  let!(:home_landing) { create :landing, slug: 'accueil', title: 'Accueil' }

  before { get "/llms.txt" }

  it "is served as text/plain" do
    expect(response.media_type).to eq("text/plain")
  end

  it "renders the llms.txt sections" do
    expect(response.body).to include("# #{I18n.t('service_name', scope: 'landings.landings.seo')}")
    expect(response.body).to include("## Aide aux entreprises")
    expect(response.body).to include("## À propos")
  end

  it "lists the home landing" do
    expect(response.body).to include("/aide-entreprise")
  end
end
