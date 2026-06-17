require "rails_helper"

RSpec.describe LLMGenerator do
  describe ".perform" do
    subject(:content) { described_class.perform }

    let!(:home_landing) { create :landing, slug: 'accueil', title: 'Accueil' }
    let!(:other_landing) { create :landing, slug: 'relance', title: 'Plan de relance' }
    let!(:archived_landing) { create :landing, slug: 'old', title: 'Obsolète', archived_at: 1.day.ago }

    it "starts with the service name as H1 and a summary blockquote" do
      expected_name = I18n.t('service_name', scope: 'landings.landings.seo')
      expect(content).to start_with("# #{expected_name}\n")
      expect(content).to include("\n> #{I18n.t('service_description', scope: 'landings.landings.seo')}")
    end

    it "explains how the service works, after the summary and before the first section" do
      how_it_works = I18n.t('service_how_it_works', scope: 'landings.landings.seo')
      expect(content).to include(how_it_works)
      expect(content.index(how_it_works)).to be < content.index("## Aide aux entreprises")
    end

    it "includes the content sections" do
      expect(content).to include("## Aide aux entreprises")
      expect(content).to include("## À propos")
    end

    it "lists non-archived landings with absolute URLs" do
      expect(content).to include("[Accueil](http")
      expect(content).to include("/aide-entreprise/accueil")
      expect(content).to include("/aide-entreprise/relance")
    end

    it "excludes archived landings" do
      expect(content).not_to include("/aide-entreprise/old")
    end

    it "lists the 'about' pages that describe the service" do
      expect(content).to include("comment_ca_marche")
      expect(content).to include("/equipe")
      expect(content).to include("/temoignages")
      expect(content).to include("/stats")
      expect(content).to include("/accessibilite")
    end

    it "excludes the regulatory pages" do
      expect(content).not_to include("/cgu")
      expect(content).not_to include("/mentions_legales")
      expect(content).not_to include("/mentions_d_information")
    end
  end
end
