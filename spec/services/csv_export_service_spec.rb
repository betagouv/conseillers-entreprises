require 'rails_helper'

describe CsvExportService do
  describe '#csv Antennes' do
    subject { described_class.csv Antenne.all }

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

  describe '#csv User' do
    let(:institution) { create :institution, name: 'Test Institution' }
    let(:antenne) { create :antenne, institution: institution, name: 'Test Antenne' }
    let!(:user) { create :user, antenne: antenne, full_name: 'User 1', email: 'user@user.com', phone_number: '0123456789', role: 'User Role' }

    describe 'simple user export' do
      subject { described_class.csv User.all }

      it do
        csv = <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction
          Test Institution,Test Antenne,User 1,user@user.com,0123456789,User Role
        CSV
        is_expected.to eq csv
      end
    end
  end
end
