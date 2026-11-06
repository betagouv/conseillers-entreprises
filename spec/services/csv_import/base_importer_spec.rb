require 'rails_helper'

describe CsvImport::BaseImporter, CsvImport do
  describe "ignore blank lines" do
    subject(:result) { CsvImport::UserImporter.import(csv, institution: institution) }

    let(:institution) { create :institution, name: 'The Institution' }

    before { create :antenne, name: 'The Antenne', institution: institution }

    context "with commas" do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe
          ,, ,,
        CSV
      end

      it { expect(result).to be_success }
    end

    context "with semicolons" do
      let(:csv) do
        <<~CSV
          Institution;Antenne;Prénom et nom;Email;Téléphone;Fonction
          The Institution;The Antenne;Marie Dupont;marie.dupont@antenne.com;0123456789;Cheffe
          ;; ;;
        CSV
      end

      it { expect(result).to be_success }
    end
  end

  describe 'automatic column separator detection' do
    subject(:importer) { CsvImport::AntenneImporter.new(csv, institution: institution) }

    let(:institution) { create :institution, name: 'Test Institution' }

    context 'no error' do
      context 'commas' do
        let(:csv) do
          <<~CSV
            Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions
            Test Institution,Antenne1,72110,,,
          CSV
        end

        it do
          expect(importer.col_sep).to eq ","
          expect(importer.import).to be_success
        end
      end

      context 'semicolons' do
        let(:csv) do
          <<~CSV
            Institution;Nom;Codes INSEE;Codes EPCI;Codes départements;Codes régions
            Test Institution;Antenne1;72110;;;
          CSV
        end

        it do
          expect(importer.col_sep).to eq ";"
          expect(importer.import).to be_success
        end
      end
    end
  end

  describe 'header errors' do
    subject(:result) { CsvImport::AntenneImporter.import(csv, institution: institution) }

    let(:institution) { create :institution, name: 'Test Institution' }

    let(:csv) do
      <<~CSV
        Institution,Nom,Codes INSEE,Foo
        Test Institution,Antenne1,72110
      CSV
    end

    it do
      expect(result).not_to be_success
      expect(result.header_errors.map(&:message)).to contain_exactly('Foo')
    end
  end

  describe 'commit' do
    let(:csv) do
      <<~CSV
        Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction
        The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe
      CSV
    end

    before do
      institution = create(:institution, name: 'The Institution')
      create(:antenne, name: 'The Antenne', institution: institution)
      CsvImport::UserImporter.import(csv, institution: institution, commit: commit)
    end

    subject(:imported_user) { User.find_by(email: "marie.dupont@antenne.com") }

    context "commit = false" do
      let(:commit) { false }

      it { expect(imported_user).to be_nil }
    end

    context "commit = true" do
      let(:commit) { true }

      it { expect(imported_user).to be_persisted }
    end
  end
end
