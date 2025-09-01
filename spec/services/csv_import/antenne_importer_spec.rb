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
      expect(result.header_errors.map(&:message)).to contain_exactly("Unclosed quoted field in line 1.")
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
        Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions
        Test Institution,Antenne1,invalid_code
      CSV
    end

    it do
      expect(result).not_to be_success
      expect(result.header_errors).to be_empty
      expect(result.postprocess_errors.first).to eq("Échec de l’import : Erreur lors du post-traitement de l'antenne : La validation a échoué : Code Format pour commune est invalide., Code Commune non trouvé")
    end
  end

  context 'two antennes' do
    let(:csv) do
      <<~CSV
        Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions,Nom du responsable,Email du responsable,Téléphone du responsable
        Test Institution,Antenne1,01037 01038,,,,Mariane Martin, mariane.m@gouv.fr,0123456789
        Test Institution,Antenne2,,,22 35,,
      CSV
    end

    it do
      expect(result).to be_success
      expect(result.objects.count).to eq 2
      expect(Antenne.find_by(name: 'Antenne1').territorial_zones.zone_type_commune.pluck(:code)).to eq %w[01037 01038]
      expect(Antenne.find_by(name: 'Antenne2').territorial_zones.zone_type_departement.pluck(:code)).to eq %w[22 35]
      expect(Antenne.find_by(name: 'Antenne1').managers.first.full_name).to eq 'Mariane Martin'
      expect(Antenne.find_by(name: 'Antenne1').managers.first.email).to eq 'mariane.m@gouv.fr'
      expect(Antenne.find_by(name: 'Antenne1').managers.first.phone_number).to eq '01 23 45 67 89'
    end
  end

  context 'tolerant headers' do
    let(:csv) do
      <<~CSV
        Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions, Nom du responsable,Email du responsable,Téléphone du responsable
        Test Institution,Antenne1,01037 01038,,,,Mariane Martin, mariane.m@gouv.fr,0123456789
      CSV
    end

    it do
      expect(result).to be_success
      expect(Antenne.find_by(name: 'Antenne1')).not_to be_nil
    end
  end

  context 'with blank rows' do
    let(:csv) { file_fixture('csv_import/antennes-with-blank-rows.csv') }

    it do
      expect(result).to be_success
      expect(Antenne.find_by(name: 'Antenne1')).not_to be_nil
    end
  end

  context 'with insee code with 4 digits' do
    let(:csv) { file_fixture('csv_import/antennes-with-4-digits-insee-codes.csv') }

    it do
      expect(result).to be_success
      expect(Antenne.find_by(name: 'Antenne1').territorial_zones.zone_type_commune.pluck(:code)).to match_array %w[06001 06002]
    end
  end

  context 'existing antenne overwrite' do
    before do
      create :antenne, institution: institution, name: 'Antenne1', territorial_zones: [create(:territorial_zone, :commune, code: '06001')]
    end

    let(:csv) do
      <<~CSV
        Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions
        Test Institution,Antenne1,06002,,,
      CSV
    end

    it do
      expect(result).to be_success
      expect(Antenne.find_by(name: 'Antenne1').territorial_zones.pluck(:code)).to eq ['06002']
    end
  end

  context 'Antenne manager' do
    context 'Add manager to existing antenne without INSEE codes' do
      before do
        create :antenne, institution: institution, name: 'Antenne1', territorial_zones: [create(:territorial_zone, :commune, code: '06001')]
      end

      let(:csv) do
        <<~CSV
          Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions,Nom du responsable,Email du responsable,Téléphone du responsable
          Test Institution,Antenne1,,,,,Mariane Martin, mariane.m@gouv.fr,0123456789
        CSV
      end

      it do
        expect(result).to be_success
        expect(Antenne.find_by(name: 'Antenne1').insee_codes).to eq ["06001"]
        expect(Antenne.find_by(name: 'Antenne1').managers.first.full_name).to eq 'Mariane Martin'
        expect(Antenne.find_by(name: 'Antenne1').managers.first.email).to eq 'mariane.m@gouv.fr'
        expect(Antenne.find_by(name: 'Antenne1').managers.first.phone_number).to eq '01 23 45 67 89'
      end
    end

    context 'Import new manager to new antenne' do
      let(:csv) do
        <<~CSV
          Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions,Nom du responsable,Email du responsable,Téléphone du responsable
           Test Institution,Antenne1,,,,,Mariane Martin, mariane.m@gouv.fr,0123456789
        CSV
      end

      it do
        expect(result).to be_success
        expect(Antenne.find_by(name: 'Antenne1').managers.size).to eq 1
        expect(Antenne.find_by(name: 'Antenne1').managers.first.email).to eq 'mariane.m@gouv.fr'
        expect(Antenne.find_by(name: 'Antenne1').managers.first.full_name).to eq 'Mariane Martin'
        expect(Antenne.find_by(name: 'Antenne1').managers.first.phone_number).to eq '01 23 45 67 89'
      end
    end

    context 'Import existing manager to existing antenne without INSEE codes' do
      let(:antenne) { create :antenne, institution: institution, name: 'Parabolique', territorial_zones: [create(:territorial_zone, :commune, code: '01037')] }
      let!(:existing_user) { create :user, full_name: 'Iznogoud', email: 'test@test.com', phone_number: '4321', antenne: antenne }

      let(:csv) do
        <<~CSV
          Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions,Nom du responsable,Email du responsable,Téléphone du responsable
          Test Institution,Parabolique,,,,,Iznogoud, test@test.com,0123456789
        CSV
      end

      it do
        expect(result).to be_success
        expect(Antenne.find_by(name: 'Parabolique').insee_codes).to eq ["01037"]
        expect(Antenne.find_by(name: 'Parabolique').managers.size).to eq 1
        expect(Antenne.find_by(name: 'Parabolique').managers).to contain_exactly(existing_user)
      end
    end

    context 'Import manager with error' do
      let(:csv) do
        <<~CSV
          Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions,Nom du responsable,Email du responsable,Téléphone du responsable
          Test Institution,Antenne1,,, mariane.m@gouv.fr,0123456789
        CSV
      end

      it do
        expect(result).not_to be_success
      end
    end

    context 'Export/Import with multiple managers (non-regression test)' do
      let!(:antenne) { create :antenne, institution: institution, name: 'Multi Manager Antenne' }
      let!(:manager1) { create :user, full_name: 'Alice Dupont', email: 'alice.dupont@example.com', phone_number: '0123456789', antenne: antenne }
      let!(:manager2) { create :user, full_name: 'Bob Martin', email: 'bob.martin@example.com', phone_number: '0987654321', antenne: antenne }
      let!(:manager3) { create :user, full_name: 'Claire Leroy', email: 'claire.leroy@example.com', phone_number: '0147258369', antenne: antenne }

      before do
        antenne.managers << [manager1, manager2, manager3]
      end

      it 'successfully exports and re-imports antenne with multiple managers' do
        # Export the antenne to CSV
        export_result = Antenne.where(id: antenne.id).export_csv
        
        # Verify the export contains multiple managers in comma-separated format
        csv_lines = export_result.csv.lines
        expect(csv_lines.size).to eq 2 # header + data
        
        data_line = csv_lines[1]
        expect(data_line).to include('Alice Dupont, Bob Martin, Claire Leroy')
        expect(data_line).to include('alice.dupont@example.com, bob.martin@example.com, claire.leroy@example.com')
        expect(data_line).to include('01 23 45 67 89, 09 87 65 43 21, 01 47 25 83 69')

        # Import the same CSV back
        import_result = institution.antennes.import_csv(export_result.csv, institution: institution)
        
        # Verify import success
        expect(import_result).to be_success
        expect(import_result.header_errors).to be_empty
        expect(import_result.preprocess_errors).to be_empty
        expect(import_result.postprocess_errors).to be_empty
        expect(import_result.objects.first.errors).to be_empty

        # Verify the antenne still has all managers
        reloaded_antenne = Antenne.find_by(name: 'Multi Manager Antenne')
        expect(reloaded_antenne.managers.count).to eq 3
        expect(reloaded_antenne.managers.pluck(:email)).to contain_exactly(
          'alice.dupont@example.com',
          'bob.martin@example.com', 
          'claire.leroy@example.com'
        )
      end
    end
  end

  context 'existing antenne tolerant name' do
    let!(:antenne) { create :antenne, institution: institution, name: 'Antenne1', territorial_zones: [create(:territorial_zone, :commune, code: '01037')] }

    let(:csv) do
      <<~CSV
        Institution,Nom,Codes INSEE,Codes EPCI,Codes départements,Codes régions
        Test Institution, antenne1 ,01037,,,
      CSV
    end

    it do
      expect(result).to be_success
      expect(Antenne.find_by(name: 'Antenne1').territorial_zones.pluck(:code)).to eq ['01037']
    end
  end
end
