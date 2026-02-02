require 'rails_helper'

# SolicitationExporter exports both solicitations with and without matches in a single CSV.
# - Solicitations WITH matches: delegated to MatchExporter (tested in match_exporter_spec.rb)
# - Solicitations WITHOUT matches: uses SolicitationExporter.fields
# This test has NO match to specifically test SolicitationExporter.fields
describe CsvExport::SolicitationExporter, CsvExport do
  subject { Solicitation.all.export_csv.csv }

  let!(:date) { d = DateTime.parse('3rd Feb 2022 04:05:06+01:00') }
  let!(:solicitation) { create :solicitation, created_at: date, id: 1234, full_name: 'Dennis Meadows', email: 'meadows@fossil.com', phone_number: 'xx', siret: '12345678900011', description: 'Description', landing_subject: landing_subject, status: :processed, form_info: { origin_id: 'aze123', origin_url: 'www.example.fr' } }
  let!(:diagnosis) { create :diagnosis, solicitation: solicitation, facility: facility, advisor: create(:user, full_name: 'Valérie Masson-Delmotte') }
  let!(:facility) { create :facility, code_effectif: 12, naf_code: '4618Z', siret: '12345678900011', insee_code: "22100", company: create(:company, name: 'Fossil', legal_form_code: "5710",) }
  let!(:region) { DecoupageAdministratif::Region.new(code: '53', nom: 'Bretagne', zone: "metro") }
  let!(:pde_theme) { create :theme, label: 'Environnement' }
  let!(:pde_subject) { create :subject, label: 'Energie', theme: pde_theme }
  let!(:landing_theme) { create :landing_theme, title: 'Environnement, transition écologique et RSE' }
  let!(:landing_subject) { create :landing_subject, title: "Gestion de l'énergie", landing_theme: landing_theme, subject: pde_subject }

  before do
    ENV['HOST_NAME'] = 'test-env'
    allow_any_instance_of(Facility).to receive(:region).and_return(region)
  end

  it do
    csv = <<~CSV
      Date de création de la sollicitation,Id de la sollicitation,Description de la sollicitation,Type de source,Intitulé de la source,Détail de la source,Id de la page d’origine,Id GA,Thématique choisie sur le site,Sujet choisi sur le site,SIRET,Commune,Région de l’établissement,Nom de l’entreprise,Catégorie juridique,Code NAF,Codes NAFA,Effectifs,Nature de l’entreprise,Nature des activités,Contact en entreprise,Adresse mail du contact entreprise,Téléphone du contact entreprise,Tags de l’équipe,Statut de la sollicitation,Date de transmission du besoin,Identifiant du besoin,Conseiller,Thème réel,Sujet réel,Id de la mise en relation,Id de l'expert,Expert,Antenne de l’expert,Institution de l’expert,Statut de la mise en relation,Date de prise en charge,Date de cloture,Statut du besoin,Date d’envoi mail de la dernière chance,Date d’abandon,Date d’archivage,Page besoin,Satisfaction - rappel,Satisfaction - utilité,Commentaire de satisfaction
      #{I18n.l(date, format: :admin)},1234,Description,,,www.example.fr,aze123,,"#{landing_theme.title}",#{pde_subject.label},12345678900011,#{facility.readable_locality},Bretagne,Fossil,"SAS, société par actions simplifiée",4618Z,"",20 à 49 salariés,"","",Dennis Meadows,meadows@fossil.com,xx,,Mise en relation
    CSV
    is_expected.to eq csv
  end
end
