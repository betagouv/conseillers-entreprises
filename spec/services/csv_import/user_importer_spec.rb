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

  context 'add user to existing team' do
    let!(:expert_antenne) { create :antenne, name: 'Antenna', institution: institution }
    let!(:expert) { create :expert, email: 'equipe@antenne.com', antenne: expert_antenne }

    context 'without typo' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Fonction de l’équipe
          The Institution,Antenna,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,Equipe,equipe@antenne.com,0987654321,Equipe des chefs
        CSV
      end

      it do
        expect(result).to be_success
        expect(institution.experts.teams.count).to eq 1
        team = institution.experts.teams.first
        expect(team.email).to eq 'equipe@antenne.com'
        expect(team.role).to eq 'Equipe des chefs'
        expect(team.users.count).to eq 2
        expect(User.find_by(email: 'marie.dupont@antenne.com').experts).to include(expert)
      end
    end

    context 'with tab before expert email' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Fonction de l’équipe
          The Institution,	Antenna,Mario Dupont,mario.dupont@antenne.com,0123456789,Cheffe,Equipe,	equipe@antenne.com  ,0987654321,Equipe des chefs
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

  context 'failing teams' do
    let(:csv) do
      <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Fonction de l’équipe
        The Institution,The Antenne,Marie Dupont,marie.dupont@antenne.com,0123456789,Cheffe,Equipe,equipe@antenne.com,,Equipe des chefs
      CSV
    end

    it do
      expect(result).not_to be_success
      first_error = result.objects.first.errors.details.dig(:experts, -1)
      expect(first_error).not_to be_nil
      expect(first_error[:error]).to eq :invalid
      invalid_experts = first_error[:value]
      expect(invalid_experts).not_to be_nil
      expect(invalid_experts.flat_map{ |e| e.errors.details }).to eq [{}, { :"phone_number" => [{ error: :blank }] }]
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

    context 'merge the subjects of users in the same team' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Fonction de l’équipe,First IS,Second IS
          The Institution,The Antenne,Marie,marie@a.a,0123456789,Superchef,Equipe,equipe@a.a,0123456789,Equipe,oui,
          The Institution,The Antenne,Marco,marco@a.a,0123456789,Directeur,Equipe,equipe@a.a,0123456789,Equipe,,oui
          The Institution,The Antenne,Maria,maria@a.a,0123456789,Directora,Equipe,equipe@a.a,0123456789,Equipe,,
          The Institution,The Antenne,Maria,marin@a.a,0123456789,Directoro,Equipe,equipe@a.a,0123456789,Equipe,oui,oui
        CSV
      end

      it do
        expect(result).to be_success
        team = Expert.teams.first
        expect(team.users.count).to eq 4
        expect(team.experts_subjects.count).to eq 2
        expect(team.institutions_subjects.pluck(:description)).to eq ['First IS', 'Second IS']
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
        expect(invalid_experts.flat_map{ |e| e.errors.details }).to eq [{ :"experts_subjects.institution_subject" => [{ error: :blank }] }]
      end
    end

    context 'merge the subjects of users in the same team' do
      let(:csv) do
        <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Fonction de l’équipe,Sujet
          The Institution,The Antenne,Marie,marie@a.a,0123456789,Superchef,Equipe,equipe@a.a,0123456789,Equipe,First IS
          The Institution,The Antenne,Marco,marco@a.a,0123456789,Directeur,Equipe,equipe@a.a,0123456789,Equipe,Second IS
          The Institution,The Antenne,Maria,maria@a.a,0123456789,Directora,Equipe,equipe@a.a,0123456789,Equipe,
          The Institution,The Antenne,Maria,marin@a.a,0123456789,Directoro,Equipe,equipe@a.a,0123456789,Equipe,First IS
        CSV
      end

      it do
        expect(result).to be_success
        team = Expert.teams.first
        expect(team.users.count).to eq 4
        expect(team.experts_subjects.count).to eq 2
        expect(team.institutions_subjects.pluck(:description)).to eq ['First IS', 'Second IS']
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
        expect(result.header_errors.map(&:message)).to eq ['The Subject']
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
      expect(result.objects).to eq [existing_user]
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
      expect(result.objects).to eq [existing_user]
      expect(existing_user.full_name).to eq 'Marie Dupont'
      expect(existing_user.institution).to eq institution
      expect(other_antenne.advisors).to be_empty
    end
  end
end
