require 'rails_helper'

describe CsvExport::AntenneExporter, CsvExport do
  let(:institution) { create :institution, name: 'Test Institution' }
  let!(:antenne1) { create :antenne, name: 'Antenne 1', institution: institution }
  let!(:antenne2) { create :antenne, name: 'Antenne 2', institution: institution }
  let!(:user) { create :user, :manager, email: 'mariane.m@gouv.fr', full_name: 'Mariane Martin', phone_number: '0123456789', antenne: antenne2 }
  let!(:commune_zone) { create(:territorial_zone, :commune, code: '75056', zoneable: antenne1) }
  let!(:epci_zone) { create(:territorial_zone, :epci, code: '200000172', zoneable: antenne1) }
  let!(:departement_zone) { create(:territorial_zone, :departement, code: '75', zoneable: antenne2) }
  let!(:region_zone) { create(:territorial_zone, :region, code: '11', zoneable: antenne2) }

  subject { Antenne.all.export_csv.csv }

  it do
    csv = <<~CSV
      Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions,Nom du responsable,Email du responsable,Téléphone du responsable
      Test Institution,Antenne 1,75056,200000172,,,,,
      Test Institution,Antenne 2,,,75,11,Mariane Martin,mariane.m@gouv.fr,01 23 45 67 89
    CSV
    is_expected.to eq csv
  end
end
