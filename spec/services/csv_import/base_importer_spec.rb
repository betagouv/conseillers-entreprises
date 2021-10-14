require 'rails_helper'

describe CsvImport::BaseImporter, CsvImport do
  describe 'with blank line' do
    subject(:result) { Antenne.import_csv(csv, institution: institution) }

    let(:institution) { create :institution, name: 'Test Institution' }

    context 'blank row' do
      let(:csv) do
        <<~CSV
          Institution,Nom,Codes communes
          Test Institution,Antenne1,12345
          ,,
          Test Institution,Antenne2,23456
        CSV
      end

      it { is_expected.to be_success }
    end
  end

  describe 'automatic column separator detection' do
    subject(:result) { Antenne.import_csv(csv, institution: institution) }

    let(:institution) { create :institution, name: 'Test Institution' }

    context 'no error' do
      context 'commas' do
        let(:csv) do
          <<~CSV
            Institution,Nom,Codes communes
            Test Institution,Antenne1,12345
          CSV
        end

        it { is_expected.to be_success }
      end

      context 'semicolons' do
        let(:csv) do
          <<~CSV
            Institution;Nom;Codes communes
            Test Institution;Antenne1;12345
          CSV
        end

        it { is_expected.to be_success }
      end
    end

    context 'header errors' do
      context 'commas' do
        let(:csv) do
          <<~CSV
            Institution,Nom,Codes communes,Foo
            Test Institution,Antenne1,12345
          CSV
        end

        it do
          expect(result).not_to be_success
          expect(result.header_errors.map(&:message)).to match_array ['Foo']
        end
      end

      context 'semicolons' do
        let(:csv) do
          <<~CSV
            Institution;Nom;Codes communes;Foo
            Test Institution;Antenne1;12345
          CSV
        end

        it do
          expect(result).not_to be_success
          expect(result.header_errors.map(&:message)).to match_array ['Foo']
        end
      end
    end
  end
end
