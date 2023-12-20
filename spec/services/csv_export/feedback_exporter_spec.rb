require 'rails_helper'

describe CsvExport::FeedbackExporter, CsvExport do
  subject { Feedback.category_need.all.export_csv.csv }

  let!(:date) { d = DateTime.parse('3rd Feb 2022 04:05:06+01:00') }
  let!(:solicitation) { create :solicitation, created_at: date, id: 1234, full_name: 'Dennis Meadows', email: 'meadows@fossil.com', phone_number: 'xx', siret: '12345678900011', description: 'Description', landing_subject: landing_subject, status: :processed, landing: landing, form_info: { origin_id: 'test123', origin_url: 'www.example.fr' } }
  let!(:landing) { create :landing, landing_themes: [landing_theme], integration: :iframe, slug: 'landing-slug', partner_url: "www.example.fr" }
  let!(:need) { create :need, diagnosis: diagnosis, subject: pde_subject }
  let!(:diagnosis) { create :diagnosis, solicitation: solicitation, facility: facility, advisor: create(:user, full_name: 'Valérie Masson-Delmotte') }
  let!(:facility) { create :facility, code_effectif: 12, naf_code: '4618Z', siret: '12345678900011', commune: commune, company: create(:company, name: 'Fossil', inscrit_rcs: true, legal_form_code: "5710",) }
  let!(:commune) { create :commune, insee_code: '22100', territories: [region] }
  let!(:region) { create :territory, :region, name: 'Région Bretagne' }
  let!(:match) { create :match, need: need, created_at: date, status: :taking_care, subject: pde_subject, expert: expert }
  let!(:user) { create :user, full_name: 'Christophe Cassou', experts: [expert], antenne: antenne }
  let!(:expert) { create :expert, full_name: 'Christophe Cassou', antenne: antenne }
  let!(:antenne) { create :antenne, name: 'GIEC Bretagne', institution: create(:institution, name: 'GIEC') }
  let!(:pde_theme) { create :theme, label: 'Environnement' }
  let!(:pde_subject) { create :subject, label: 'Energie', theme: pde_theme }
  let!(:landing_theme) { create :landing_theme, title: 'Environnement, transition écologique et RSE' }
  let!(:landing_subject) { create :landing_subject, title: "Gestion de l'énergie", landing_theme: landing_theme, subject: pde_subject }
  let!(:feedback1) { create :feedback, :for_need, feedbackable: need, user: user, description: 'Premier commentaire.' }
  let!(:feedback2) { create :feedback, :for_need, feedbackable: need, user: user, description: 'Deuxième commentaire' }
  let!(:company_satisfaction) { create :company_satisfaction, need: need, contacted_by_expert: true, useful_exchange: false, comment: 'Commentaire de satisfaction' }

  before { ENV['HOST_NAME'] = 'test-env' }

  it do
    csv = <<~CSV
      Type de source,Intitulé de la source,Détail de la source,Identifiant du besoin,Date de création du besoin,SIRET,Thème réel,Sujet réel,Statut du besoin,Date de clôture du besoin,Statut de la mise en relation,Date de cloture,Institution,Antenne de l’expert,Commentaires des conseillers de l’antenne,Satisfaction - rappel,Satisfaction - utilité,Commentaire de satisfaction,Page besoin
      Iframe,landing-slug,www.example.fr,#{need.id},#{I18n.l(need.created_at, format: :admin)},12345678900011,Environnement,Energie,En cours de prise en charge,,Pris en charge,,GIEC,GIEC Bretagne,"- Premier commentaire.\n- Deuxième commentaire",oui,non,Commentaire de satisfaction,http://test.host/besoins/#{need.id}
    CSV
    is_expected.to eq csv
  end
end
