require 'rails_helper'

describe CsvImport do
  describe 'automatic column separator detection' do
    subject(:result) { CsvImport::AntenneImporter.import(csv) }

    before do
      create :institution, name: 'Test Institution'
    end

    context 'no error' do
      context 'commas' do
        let(:csv) do
          <<~CSV
            Institution,Nom,Codes commune
            Test Institution,Antenne1,12345
          CSV
        end

        it { is_expected.to be_success }
      end

      context 'semicolons' do
        let(:csv) do
          <<~CSV
            Institution;Nom;Codes commune
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
            Institution,Nom,Codes commune,Foo
            Test Institution,Antenne1,12345
          CSV
        end

        it do
          expect(result).not_to be_success
          expect(result.header_errors.map(&:message)).to eq ['En-tête non reconnu: « Foo »']
        end
      end

      context 'semicolons' do
        let(:csv) do
          <<~CSV
            Institution;Nom;Codes commune;Foo
            Test Institution;Antenne1;12345
          CSV
        end

        it do
          expect(result).not_to be_success
          expect(result.header_errors.map(&:message)).to eq ['En-tête non reconnu: « Foo »']
        end
      end
    end
  end

  describe 'import antennes' do
    subject(:result) { CsvImport::AntenneImporter.import(csv) }

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
        expect(result.header_errors.map(&:message)).to eq [
          'En-tête non reconnu: « Foo »',
          'En-tête non reconnu: « Bar »'
        ]
      end
    end

    context 'invalid rows' do
      before do
        create :institution, name: 'Test Institution'
      end

      let(:csv) do
        <<~CSV
          Institution,Nom,Codes commune
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
      before do
        create :institution, name: 'Test Institution'
      end

      let(:csv) do
        <<~CSV
          Institution,Nom,Codes commune
          Test Institution,Antenne1,00001 00002
          Test Institution,Antenne2,00003 00004
        CSV
      end

      it do
        expect(result).to be_success
        expect(result.objects.count).to eq 2
        expect(result.objects.map(&:name)).to eq %w[Antenne1 Antenne2]
        expect(Commune.pluck(:insee_code)).to match_array %w[00001 00002 00003 00004]
      end
    end

    context 'existing antenne overwrite' do
      before do
        institution = create :institution, name: 'Test Institution'
        create :antenne, institution: institution, name: 'Antenne1', insee_codes: '00001'
      end

      let(:csv) do
        <<~CSV
          Institution,Nom,Codes commune
          Test Institution,Antenne1,00002
        CSV
      end

      it do
        expect(result).to be_success
        expect(Antenne.find_by(name: 'Antenne1').insee_codes).to eq '00002'
      end
    end
  end

  describe 'import advisors' do
    subject(:result) { CsvImport::UserImporter.import(csv, institution) }

    let(:institution) { create :institution, name: 'The Institution' }
    let(:theme) { create :theme, label: 'The Theme' }
    let(:the_subject) { create :subject, label: 'The Subject', theme: theme }

    before do
      create :antenne, name: 'The Antenne', institution: institution
      create :institution_subject, institution: institution, subject: the_subject, description: 'First IS'
      create :institution_subject, institution: institution, subject: the_subject, description: 'Second IS'
    end

    context 'two users, no team' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe
          The Institution,The Antenne,Mario Dupont,mario.dupont@antenne.com,0123456789,Sous-Chef
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.advisors.pluck(:email)).to match_array(['marie.dupont@antenne.com', 'mario.dupont@antenne.com'])
      end
    end

    context 'set teams' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Fonction de l’équipe
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,Equipe,equipe@antenne.com,0987654321,Equipe des chefs
          The Institution,The Antenne,Mario Dupont,mario.dupont@antenne.com,0123456789,Sous-Chef,Equipe,equipe@antenne.com,0987654321,Equipe des chefs
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(team.role).to eq 'Equipe des chefs'
        expect(team.users.pluck(:email)).to match_array(['marie.dupont@antenne.com', 'mario.dupont@antenne.com'])
      end
    end

    context 'set subjects' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,The Theme:The Subject:First IS,The Theme:The Subject:Second IS
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,spécialiste:First IS,
        CSV
      end

      it do
        expect(result).to be_success
        marie = result.objects.first
        expect(marie.personal_skillsets.count).to eq 1
        expect(marie.experts.teams.count).to eq 0
        skillet = marie.personal_skillsets.first
        expect(skillet.experts_subjects.count).to eq 1
        expect(skillet.experts_subjects.first.description).to eq 'First IS'
        expect(skillet.experts_subjects.first.subject).to eq the_subject
      end
    end

    context 'overwrite existing user' do
      let(:other_antenne) { create :antenne, name: 'Other' }
      let!(:existing_user) { create :user, full_name: 'TestUser', email: 'test@test.com', phone_number: '4321', antenne: other_antenne }

      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction
          The Institution,The Antenne,Marie Dupont,test@test.com,0123456789,Cheffe
        CSV
      end

      it do
        expect(result).to be_success
        existing_user.reload
        expect(result.objects).to eq [existing_user]
        expect(existing_user.full_name).to eq 'Marie Dupont'
        expect(existing_user.institution).to eq institution
        expect(other_antenne.advisors).to be_empty
      end
    end
  end
end
