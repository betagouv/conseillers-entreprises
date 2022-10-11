require 'rails_helper'

describe CsvExport::MatchExporter, CsvExport do
  subject { Match.all.export_csv.csv }

  let!(:date) { d = DateTime.parse('3rd Feb 2022 04:05:06+01:00') }
  let!(:solicitation) { create :solicitation, created_at: date, id: 1234, full_name: 'Dennis Meadows', email: 'meadows@fossil.com', phone_number: 'xx', siret: '12345678900011', description: 'Description', landing_subject: landing_subject, status: :processed }
  let!(:need) { create :need, diagnosis: diagnosis }
  let!(:diagnosis) { create :diagnosis, solicitation: solicitation, facility: facility, advisor: create(:user, full_name: 'Valérie Masson-Delmotte') }
  let!(:facility) { create :facility, code_effectif: 12, naf_code: '4618Z', siret: '12345678900011', commune: commune, company: create(:company, name: 'Fossil', inscrit_rcs: true) }
  let!(:commune) { create :commune, insee_code: '22100', territories: [region] }
  let!(:region) { create :territory, :region, name: 'Région Bretagne' }
  let!(:match) { create :match, need: need, created_at: date, status: :taking_care, subject: pde_subject, expert: expert }
  let!(:expert) { create :expert, full_name: 'Christophe Cassou', antenne: antenne  }
  let!(:antenne) { create :antenne, name: 'GIEC Bretagne', institution: create(:institution, name: 'GIEC') }
  let!(:pde_theme) { create :theme, label: 'Environnement' }
  let!(:pde_subject) { create :subject, label: 'Energie', theme: pde_theme }
  let!(:landing_theme) { create :landing_theme, title: 'Environnement, transition écologique et RSE' }
  let!(:landing_subject) { create :landing_subject, title: "Gestion de l'énergie", landing_theme: landing_theme, subject: pde_subject }

  before { ENV['HOST_NAME'] = 'test-env' }

  it do
    csv = <<~CSV
      Date de sollicitation,Id de la sollicitation,Description de la sollicitation,Type de source,Intitulé de la source,Détail de la source,Id GA,Thème choisi sur le site,Sujet choisi sur le site,SIRET,Commune,Région de l’établissement,Nom de l’entreprise,Code NAF,Effectifs,Inscrit rcs,Inscrit rm,Contact en entreprise,Adresse mail du contact entreprise,Téléphone du contact entreprise,Tags de l’équipe,Statut de la sollicitation,Date de transmission du besoin,Identifiant du besoin,Conseiller,Thème réel,Sujet réel,Id de la mise en relation,Expert,Antenne de l’expert,Institution de l’expert,Statut de la mise en relation,Date de prise en charge,Date de cloture,Statut du besoin,Date d’archivage,Page besoin,Satisfaction - rappel,Satisfaction - utilité,Commentaire de satisfaction
      #{I18n.l(date, format: :admin)},1234,Description,,,,,"#{landing_theme.title}",#{pde_subject.label},12345678900011,22100,Région Bretagne,Fossil,4618Z,20 à 49 salariés,oui,non,Dennis Meadows,meadows@fossil.com,xx,,Mise en relation,#{I18n.l(date, format: :admin)},#{need.id},Valérie Masson-Delmotte,Environnement,Energie,#{match.id},Christophe Cassou,GIEC Bretagne,GIEC,Pris en charge,,,En cours de prise en charge,,http://test.host/besoins/#{need.id},,,
    CSV
    is_expected.to eq csv
  end
end
