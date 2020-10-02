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

    describe 'with teams' do
      let!(:expert) { create :expert, antenne: antenne, users: [user], full_name: 'Team 1', email: 'team@team.com', phone_number: '0987654321', role: 'Team Role' }

      subject do
        additional_fields = User.csv_fields_for_relevant_expert_team
        described_class.csv User.relevant_for_skills, additional_fields
      end

      it do
        csv = <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Fonction de l’équipe
          Test Institution,Test Antenne,User 1,user@user.com,0123456789,User Role,Team 1,team@team.com,0987654321,Team Role
        CSV
        is_expected.to eq csv
      end
    end

    describe 'with subjects' do
      let(:theme) { create :theme, label: 'Test Theme' }
      let(:the_subject) { create :subject, theme: theme, label: 'Test Subject' }
      let(:institution_subject) { create :institution_subject, institution: institution, subject: the_subject, description: 'Description for institution' }
      let!(:expert_subject) { create :expert_subject, expert: user.personal_skillsets.first, institution_subject: institution_subject, description: 'Description for expert' }

      subject do
        institution.reload
        additional_fields = User.csv_fields_for_relevant_expert_subjects(institution.institutions_subjects)
        described_class.csv User.relevant_for_skills, additional_fields
      end

      it do
        csv = <<~CSV
          Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Test Theme:Test Subject:Description for institution
          Test Institution,Test Antenne,User 1,user@user.com,0123456789,User Role,Description for expert
        CSV
        is_expected.to eq csv
      end
    end
  end
end
