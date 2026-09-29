require 'rails_helper'

describe CsvImport::BaseImporter, CsvImport do
  describe "ignore blank lines" do
    subject(:result) { User.import_csv(csv, institution: institution) }

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
  end

  describe 'automatic column separator detection' do
    subject(:result) { Antenne.import_csv(csv, institution: institution) }

    let(:institution) { create :institution, name: 'Test Institution' }

    context 'no error' do
      context 'commas' do
        let(:csv) do
          <<~CSV
            Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions
            Test Institution,Antenne1,72110,,,
          CSV
        end

        it { is_expected.to be_success }
      end

      context 'semicolons' do
        let(:csv) do
          <<~CSV
            Institution;Nom;Codes INSEE;Codes EPCI;Codes départements;Codes régions
            Test Institution;Antenne1;72110;;;
          CSV
        end

        it { is_expected.to be_success }
      end
    end

    context 'header errors' do
      context 'commas' do
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

      context 'semicolons' do
        let(:csv) do
          <<~CSV
            Institution;Nom;Codes INSEE;Foo
            Test Institution;Antenne1;72110
          CSV
        end

        it do
          expect(result).not_to be_success
          expect(result.header_errors.map(&:message)).to contain_exactly('Foo')
        end
      end
    end
  end
end
