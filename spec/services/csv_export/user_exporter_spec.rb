require 'rails_helper'

describe CsvExport::UserExporter, CsvExport do
  let(:institution) { create :institution, name: 'Test Institution' }
  let(:antenne) { create :antenne, institution: institution, name: 'Test Antenne' }
  let!(:user) { create :user, antenne: antenne, full_name: 'User 1', email: 'user@user.com', phone_number: '0123456789', job: 'User job' }

  describe 'simple user export' do
    subject { User.all.export_csv.csv }

    it do
      csv = <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction
        Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job
      CSV
      is_expected.to eq csv
    end
  end

  describe 'with teams' do
    let!(:expert) { create :expert, antenne: antenne, users: [user], full_name: 'Team 1', email: 'team@team.com', phone_number: '0987654321', communes: [create(:commune, insee_code: '22101')] }

    subject { User.relevant_for_skills.export_csv(include_expert_team: true).csv }

    it do
      csv = <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Id de l’équipe,Nom de l’équipe,E-mail de l’équipe,Téléphone de l’équipe,Territoire spécifique
        Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job,#{expert.id},Team 1,team@team.com,09 87 65 43 21,22101
      CSV
      is_expected.to eq csv
    end
  end

  describe 'with subjects' do
    let(:theme) { create :theme, label: 'Test Theme' }
    let(:the_subject) { create :subject, theme: theme, label: 'Test Subject' }
    let(:institution_subject) { create :institution_subject, institution: institution, subject: the_subject, description: 'Description for institution' }
    let!(:expert_subject) { create :expert_subject, expert: user.personal_skillsets.first, institution_subject: institution_subject, intervention_criteria: 'Intervention criteria' }

    subject do
      institution.reload
      User.relevant_for_skills.export_csv(institutions_subjects: institution.institutions_subjects).csv
    end

    it do
      csv = <<~CSV
        Institution,Antenne,Prénom et nom,E-mail,Téléphone,Fonction,Test Subject
        Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job,Intervention criteria
      CSV
      is_expected.to eq csv
    end
  end
end
