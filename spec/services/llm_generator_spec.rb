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

    it "renders the contact landing with a clear title and no sub-theme" do
      theme = create :landing_theme, title: 'Échanger avec un conseiller pour :'
      create :landing, slug: 'contactez-nous', title: 'Autre sujet ?', landing_themes: [theme]
      expect(content).to include("[#{I18n.t('llms.contact.title')}]")
      expect(content).to include(": #{I18n.t('llms.contact.description')}")
      expect(content).not_to include("Échanger avec un conseiller pour")
    end

    it "lists the 'about' pages that describe the service" do
      expect(content).to include("comment_ca_marche")
      expect(content).to include("/equipe")
      expect(content).to include("/temoignages")
    end

    it "lists secondary pages under an 'Optional' section" do
      expect(content).to include("## Optional")
      expect(content).to include("/accessibilite")
      expect(content).to include("/stats")
    end

    it "places the Optional section after the About section" do
      expect(content.index("## Optional")).to be > content.index("## À propos")
    end

    it "keeps accessibilite and stats out of the About section" do
      about_section = content[/## À propos.*?(?=\n## |\z)/m]
      expect(about_section).not_to include("/accessibilite")
      expect(about_section).not_to include("/stats")
    end

    it "renders human-readable link titles, not missing translations" do
      expect(content).to include("[#{I18n.t('about.accessibilite.title')}]")
      expect(content).not_to include("translation missing")
    end

    it "nests each landing's non-archived themes under it" do
      theme = create :landing_theme, title: 'Recrutement'
      create :landing, slug: 'embauche', title: 'Embauche', landing_themes: [theme]
      expect(content).to include("  - [Recrutement](http")
    end

    it "appends the landing meta_description after the link" do
      create :landing, slug: 'esus', title: 'ESUS', meta_description: 'Entreprise solidaire'
      expect(content).to include("/aide-entreprise/esus): Entreprise solidaire")
    end

    it "appends the theme description on the nested line" do
      theme = create :landing_theme, title: 'Recrutement', description: 'Aides à l’embauche'
      create :landing, slug: 'embauche', title: 'Embauche', landing_themes: [theme]
      expect(content).to include(": Aides à l’embauche")
    end

    it "squishes whitespace in titles" do
      create :landing, slug: 'spaced', title: "  Titre   à   espaces  "
      expect(content).to include("[Titre à espaces]")
      expect(content).not_to include("Titre   à")
    end

    it "lists the regulatory pages under the Optional section" do
      optional_section = content[/## Optional.*\z/m]
      expect(optional_section).to include("/cgu")
      expect(optional_section).to include("/mentions_legales")
      expect(optional_section).to include("/mentions_d_information")
    end
  end

  describe ".link_line" do
    it "formats a link with a squished description after a colon" do
      expect(described_class.link_line("Titre", "http://x", "  une   description ")).to eq("- [Titre](http://x): une description")
    end

    it "omits the colon when the description is blank" do
      expect(described_class.link_line("Titre", "http://x", nil)).to eq("- [Titre](http://x)")
      expect(described_class.link_line("Titre", "http://x", "   ")).to eq("- [Titre](http://x)")
    end

    it "squishes the title" do
      expect(described_class.link_line("  Mon   titre ", "http://x")).to eq("- [Mon titre](http://x)")
    end
  end
end
