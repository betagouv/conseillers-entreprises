require 'rails_helper'

describe CsvImport::UserImporter, CsvImport do
  subject(:result) { User.import_csv(csv, institution: institution) }

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
      expect(institution.experts.teams.count).to eq 0
      expect(result).to be_success
      expect(institution.advisors.pluck(:email)).to match_array(['marie.dupont@antenne.com', 'mario.dupont@antenne.com'])
    end
  end

  context 'set teams' do
    describe 'without typo' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,Equipe,equipe@antenne.com,0987654321
          The Institution,The Antenne,Mario Dupont,mario.dupont@antenne.com,0123456789,Sous-Chef,Equipe,equipe@antenne.com,0987654321
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(team.job).to be_nil
        expect(team.users.pluck(:email)).to match_array(['marie.dupont@antenne.com', 'mario.dupont@antenne.com'])
      end
    end

    describe 'witout 0 in phone number' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,123456789,Cheffe,Equipe,equipe@antenne.com,987654321
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.phone_number).to eq '09 87 65 43 21'
        expect(team.users.pluck(:phone_number)).to match_array(['01 23 45 67 89'])
      end
    end

    describe 'with accent in email' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe
          The Institution,The Antenne,Marie Dupont,marie.dùpont@antênne.com,0123456789,Cheffe,Equipe,équîpe@ântènne.com,0987654321
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(team.users.pluck(:email)).to match_array(['marie.dupont@antenne.com'])
      end
    end

    describe 'with non-breaking space in email' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com ,0123456789,Cheffe,Equipe,équîpe@ântènne.com,0987654321
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(team.users.pluck(:email)).to match_array(['marie.dupont@antenne.com'])
      end
    end

    context 'replace comma and semicolon with dots in emails' do
      let(:csv) { file_fixture('csv_import/users-with-comma-in-emails.csv') }

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(team.users.pluck(:email)).to match_array(['marie.dupont@antenne.com'])
      end
    end
  end

  context 'set teams and user without phone number' do
    let(:csv) do
      <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe
        The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,,Cheffe,Equipe,equipe@antenne.com,
        The Institution,The Antenne,Mario Dupont,mario.dupont@antenne.com,,Sous-Chef,Equipe,equipe@antenne.com,
      CSV
    end

    it do
      expect(result).to be_success
      expect(institution.experts.teams.count).to eq 1
      team = institution.experts.teams.first
      expect(team.email).to eq 'equipe@antenne.com'
      expect(team.job).to be_nil
      expect(team.users.pluck(:email)).to match_array(['marie.dupont@antenne.com', 'mario.dupont@antenne.com'])
    end
  end

  context 'add user to existing team' do
    let!(:expert_antenne) { create :antenne, name: 'Antenna', institution: institution }
    let!(:expert) { create :expert_with_users, email: 'equipe@antenne.com', antenne: expert_antenne }

    context 'without typo' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe
          The Institution,Antenna,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,Equipe,equipe@antenne.com,0987654321
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(team.job).to be_nil
        expect(team.users.count).to eq 2
        expect(User.find_by(email: 'marie.dupont@antenne.com').experts).to include(expert)
      end
    end

    context 'with tab before expert email' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe
          The Institution,Antenna,Mario Dupont,   mario.dupont@antenne.com,0123456789,Cheffe,Equipe,	equipe@antenne.com  ,0987654321
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(User.find_by(email: 'mario.dupont@antenne.com').experts).to include(expert)
      end
    end

    context 'with tab and no capital letter in antenne name' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe
          The Institution,  antenna,Mario Dupont,mario.dupont@antenne.com,0123456789,Cheffe,Equipe,	equipe@antenne.com  ,0987654321
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(User.find_by(email: 'mario.dupont@antenne.com').experts).to include(expert)
      end
    end
  end

  context 'set subjects with subject-specific columns' do
    context 'single user' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,The Theme:The Subject:First IS,The Theme:The Subject:Second IS
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,First ES,
        CSV
      end

      it do
        expect(result).to be_success
        marie = result.objects.first
        expect(marie.personal_skillsets.count).to eq 1
        expect(marie.experts.teams.count).to eq 0
        skillet = marie.personal_skillsets.first
        expect(skillet.experts_subjects.count).to eq 1
        expect(skillet.experts_subjects.first.intervention_criteria).to eq 'First ES'
        expect(skillet.experts_subjects.first.subject).to eq the_subject
      end
    end

    context 'different users, same team, different subjects' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,First IS,Second IS
          The Institution,The Antenne,Marie,marie@a.a,0123456789,Superchef,Equipe,equipe@a.a,0123456789,oui,
          The Institution,The Antenne,Marco,marco@a.a,0123456789,Directeur,Equipe,equipe@a.a,0123456789,,oui
          The Institution,The Antenne,Maria,maria@a.a,0123456789,Directora,Equipe,equipe@a.a,0123456789,,
          The Institution,The Antenne,Maria,marin@a.a,0123456789,Directoro,Equipe,equipe@a.a,0123456789,oui,oui
        CSV
      end

      it do
        expect(result).not_to be_success
      end
    end

    context 'different users, same team, same subjects' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,First IS,Second IS
          The Institution,The Antenne,Marie,marie@a.a,0123456789,Superchef,Equipe,equipe@a.a,0123456789,,oui
          The Institution,The Antenne,Marco,marco@a.a,0123456789,Directeur,Equipe,equipe@a.a,0123456789,,oui
          The Institution,The Antenne,Maria,maria@a.a,0123456789,Directora,Equipe,equipe@a.a,0123456789,,oui
          The Institution,The Antenne,Maria,marin@a.a,0123456789,Directoro,Equipe,equipe@a.a,0123456789,,oui
        CSV
      end

      it do
        expect(result).to be_success
        team = Expert.teams.first
        expect(team.users.count).to eq 4
        expect(team.experts_subjects.count).to eq 1
        expect(team.institutions_subjects.pluck(:description)).to match_array ['Second IS']
      end
    end
  end

  context 'set subjects with one single column' do
    context 'no error' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Sujet
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,The Theme:The Subject:First IS
        CSV
      end

      it do
        expect(result).to be_success
        marie = result.objects.first
        expect(marie.personal_skillsets.count).to eq 1
        expect(marie.experts.teams.count).to eq 0
        skillet = marie.personal_skillsets.first
        expect(skillet.experts_subjects.count).to eq 1
        expect(skillet.experts_subjects.first.intervention_criteria).to be_blank
        expect(skillet.experts_subjects.first.subject).to eq the_subject
      end
    end

    context 'subject not found' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Sujet
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,Inconnu
        CSV
      end

      it do
        expect(result).not_to be_success
        first_error = result.objects.first.errors.details.dig(:experts, -1)
        expect(first_error).not_to be_nil
        expect(first_error[:error]).to eq :invalid
        invalid_experts = first_error[:value]
        expect(invalid_experts).not_to be_nil
        expect(invalid_experts.flat_map{ |e| e.errors.details }).to match_array [{ :'experts_subjects.institution_subject' => [{ error: :blank }] }]
      end
    end

    context 'merge the subjects of users in the same team' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Sujet
          The Institution,The Antenne,Marie,marie@a.a,0123456789,Superchef,Equipe,equipe@a.a,0123456789,First IS
          The Institution,The Antenne,Marco,marco@a.a,0123456789,Directeur,Equipe,equipe@a.a,0123456789,Second IS
          The Institution,The Antenne,Maria,maria@a.a,0123456789,Directora,Equipe,equipe@a.a,0123456789,
          The Institution,The Antenne,Maria,marin@a.a,0123456789,Directoro,Equipe,equipe@a.a,0123456789,First IS
        CSV
      end

      it do
        expect(result).to be_success
        team = Expert.teams.first
        expect(team.users.count).to eq 4
        expect(team.experts_subjects.count).to eq 2
        expect(team.institutions_subjects.pluck(:description)).to match_array ['First IS', 'Second IS']
      end
    end
  end

  context 'tolerant subject matching' do
    context 'no error' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,First IS
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,Oui
        CSV
      end

      it do
        expect(result).to be_success
        marie = result.objects.first
        expect(marie.personal_skillsets.count).to eq 1
        expect(marie.experts.teams.count).to eq 0
        skillet = marie.personal_skillsets.first
        expect(skillet.experts_subjects.count).to eq 1
        expect(skillet.experts_subjects.first.intervention_criteria).to be_blank
        expect(skillet.experts_subjects.first.subject).to eq the_subject
      end
    end

    context 'imprecise match label' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,The Subject
          The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,Oui
        CSV
      end

      it do
        expect(result).not_to be_success
        expect(result.header_errors.map(&:message)).to match_array ['The Subject']
      end
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
      expect(result.objects).to match_array [existing_user]
      expect(existing_user.full_name).to eq 'Marie Dupont'
      expect(existing_user.institution).to eq institution
      expect(other_antenne.advisors).to be_empty
    end
  end

  context 'overwrite existing user with email typo' do
    let(:other_antenne) { create :antenne, name: 'Other' }
    let!(:existing_user) { create :user, full_name: 'TestUser', email: 'test@test.com', phone_number: '4321', antenne: other_antenne }

    let(:csv) do
      <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction
        The Institution,The Antenne,Marie Dupont, test@test.com,0123456789,Cheffe
      CSV
    end

    it do
      expect(result).to be_success
      existing_user.reload
      expect(result.objects).to match_array [existing_user]
      expect(existing_user.full_name).to eq 'Marie Dupont'
      expect(existing_user.institution).to eq institution
      expect(other_antenne.advisors).to be_empty
    end
  end

  context 'update existing team subjects' do
    let(:first_csv) do
      <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,First IS,Second IS
        The Institution,The Antenne,Marie,marie@a.a,0123456789,Superchef,Equipe,equipe@a.a,0123456789,oui,oui
      CSV
    end

    let(:csv) do
      <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,First IS,Second IS
        The Institution,The Antenne,Marie,marie@a.a,0123456789,Superchef,Equipe,equipe@a.a,0123456789,,oui
      CSV
    end

    before do
      User.import_csv(first_csv, institution: institution)
    end

    it do
      team = Expert.teams.first
      expect(team.experts_subjects.count).to eq 2
      expect(result).to be_success
      expect(team.experts_subjects.count).to eq 1
      expect(team.institutions_subjects.pluck(:description)).to match_array ['Second IS']
    end
  end

  context 'Don’t create antenne if the name is wrong' do
    let(:csv) do
      <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction
        The Institution,The other Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe
        The Institution,The other Antenne,Mario Dupont,mario.dupont@antenne.com,0123456789,Sous-Chef
      CSV
    end

    it do
      expect(result).not_to be_success
      expect(Antenne.count).to eq 1
    end
  end
end
