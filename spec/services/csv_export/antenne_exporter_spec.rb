require 'rails_helper'

describe CsvExport::AntenneExporter, CsvExport do
  subject { Antenne.all.export_csv.csv }

  before do
    institution = create :institution, name: 'Test Institution'
    create :antenne, institution: institution, name: 'Antenne 1', insee_codes: '12345, 67890'
    create :antenne, institution: institution, name: 'Antenne 2', insee_codes: '98765, 43210',
           manager_full_name: 'Mariane Martin', manager_email: 'mariane.m@gouv.fr', manager_phone: '0123456789'
  end

  it do
    csv = <<~CSV
      Institution,Nom,Codes commune,Nom du responsable,Email du responsable,Téléphone du responsable
      Test Institution,Antenne 1,12345 67890,,,
      Test Institution,Antenne 2,98765 43210,Mariane Martin,mariane.m@gouv.fr,0123456789
    CSV
    is_expected.to eq csv
  end
end
