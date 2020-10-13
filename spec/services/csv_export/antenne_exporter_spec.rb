require 'rails_helper'

describe CsvExport::AntenneExporter, CsvExport do
  subject { Antenne.all.export_csv.csv }

  before do
    institution = create :institution, name: 'Test Institution'
    create :antenne, institution: institution, name: 'Antenne 1', insee_codes: '12345, 67890'
    create :antenne, institution: institution, name: 'Antenne 2', insee_codes: '98765, 43210'
  end

  it do
    csv = <<~CSV
      Institution,Nom,Codes commune
      Test Institution,Antenne 1,12345 67890
      Test Institution,Antenne 2,98765 43210
    CSV
    is_expected.to eq csv
  end
end
