require 'rails_helper'

describe CsvImport::AntenneImporter, CsvImport do
  subject(:result) { Antenne.import_csv(csv, institution: institution) }

  let(:institution) { create :institution, name: 'Test Institution' }

  context 'malformed file' do
    let(:csv) do
      <<~CSV
        Institution,"
      CSV
    end

    it do
      expect(result).not_to be_success
      expect(result.header_errors.map(&:message)).to eq ["Unclosed quoted field in line 1."]
    end
  end

  context 'invalid headers' do
    let(:csv) do
      <<~CSV
        Foo,Bar
      CSV
    end

    it do
      expect(result).not_to be_success
      expect(result.header_errors.map(&:message)).to eq %w[Foo Bar]
    end
  end

  context 'invalid rows' do
    let(:csv) do
      <<~CSV
        Institution,Nom,Codes communes
        Test Institution,Antenne1,invalid_code
      CSV
    end

    it do
      expect(result).not_to be_success
      expect(result.header_errors).to be_empty
      expect(result.objects.first.errors.details).to eq({ insee_codes: [{ error: :invalid_insee_codes }] })
    end
  end

  context 'two antennes' do
    let(:csv) do
      <<~CSV
        Institution,Nom,Codes communes,Nom du responsable,Email du responsable,Téléphone du responsable
        Test Institution,Antenne1,00001 00002,Mariane Martin, mariane.m@gouv.fr,0123456789
        Test Institution,Antenne2,00003 00004
      CSV
    end

    it do
      expect(result).to be_success
      expect(result.objects.count).to eq 2
      expect(Commune.pluck(:insee_code)).to match_array %w[00001 00002 00003 00004]
      expect(Antenne.find_by(name: 'Antenne1').communes.pluck(:insee_code)).to eq %w[00001 00002]
      expect(Antenne.find_by(name: 'Antenne2').communes.pluck(:insee_code)).to eq %w[00003 00004]
      expect(Antenne.find_by(name: 'Antenne1').manager_full_name).to eq 'Mariane Martin'
      expect(Antenne.find_by(name: 'Antenne1').manager_email).to eq 'mariane.m@gouv.fr'
      expect(Antenne.find_by(name: 'Antenne1').manager_phone).to eq '0123456789'
    end
  end

  context 'existing antenne overwrite' do
    before do
      create :antenne, institution: institution, name: 'Antenne1', insee_codes: '00001'
    end

    let(:csv) do
      <<~CSV
        Institution,Nom,Codes communes
        Test Institution,Antenne1,00002
      CSV
    end

    it do
      expect(result).to be_success
      expect(Antenne.find_by(name: 'Antenne1').insee_codes).to eq '00002'
    end
  end

  context 'Add manager to existing antenne without INSEE codes' do
    before do
      create :antenne, institution: institution, name: 'Antenne1', insee_codes: '00001'
    end

    let(:csv) do
      <<~CSV
        Institution,Nom,Codes communes,Nom du responsable,Email du responsable,Téléphone du responsable
        Test Institution,Antenne1,,Mariane Martin, mariane.m@gouv.fr,0123456789
      CSV
    end

    it do
      expect(result).to be_success
      expect(Antenne.find_by(name: 'Antenne1').insee_codes).to eq '00001'
      expect(Antenne.find_by(name: 'Antenne1').manager_full_name).to eq 'Mariane Martin'
      expect(Antenne.find_by(name: 'Antenne1').manager_email).to eq 'mariane.m@gouv.fr'
      expect(Antenne.find_by(name: 'Antenne1').manager_phone).to eq '0123456789'
    end
  end

  context 'existing antenne tolerant name' do
    before do
      create :antenne, institution: institution, name: 'Antenne1', insee_codes: '00001'
    end

    let(:csv) do
      <<~CSV
        Institution,Nom,Codes communes
        Test Institution, antenne1 ,00002
      CSV
    end

    it do
      expect(result).to be_success
      expect(Antenne.find_by(name: 'Antenne1').insee_codes).to eq '00002'
    end
  end
end
