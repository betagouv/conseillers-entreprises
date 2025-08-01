require 'rails_helper'

describe CsvExport::UserExporter, CsvExport do
  let(:institution) { create :institution, name: 'Test Institution' }
  let(:antenne) { create :antenne, institution: institution, name: 'Test Antenne' }
  let!(:user) { create :user, antenne: antenne, full_name: 'User 1', email: 'user@user.com', phone_number: '0123456789', job: 'User job' }

  describe 'simple user export' do
    subject { User.all.export_csv.csv }

    it do
      csv = <<~CSV
        Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction
        Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job
      CSV
      is_expected.to eq csv
    end
  end

  describe 'with teams' do
    let!(:expert) { create :expert, :with_expert_subjects, antenne: antenne, users: [user], full_name: 'Team 1', email: 'team@team.com', phone_number: '0987654321' }

    subject { User.all.export_csv(include_expert: true).csv }

    before do
      expert.territorial_zones = territorial_zones
    end

    context "without specific territories" do
      let(:territorial_zones) { [] }

      it do
        csv = <<~CSV
          Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction,Id de l’équipe,Nom de l’équipe,Email de l’équipe,Téléphone de l’équipe,Communes spécifiques,EPCI spécifiques,Départements spécifiques,Régions spécifiques
          Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job,#{expert.id},Team 1,team@team.com,09 87 65 43 21,,,,
        CSV
        is_expected.to eq csv
      end
    end

    context "With specific communes" do
      let(:territorial_zones) do
  [
    create(:territorial_zone, :commune, code: "22118"),
    create(:territorial_zone, :commune, code: "22050")
  ]
end

      it do
        csv = <<~CSV
          Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction,Id de l’équipe,Nom de l’équipe,Email de l’équipe,Téléphone de l’équipe,Communes spécifiques,EPCI spécifiques,Départements spécifiques,Régions spécifiques
          Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job,#{expert.id},Team 1,team@team.com,09 87 65 43 21,"22118, 22050",,,
        CSV
        is_expected.to eq csv
      end
    end

    context "With specific epcis" do
      let(:territorial_zones) do
  [
    create(:territorial_zone, :epci, code: "200041499"),
    create(:territorial_zone, :epci, code: "200041762")
  ]
end

      it do
        csv = <<~CSV
          Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction,Id de l’équipe,Nom de l’équipe,Email de l’équipe,Téléphone de l’équipe,Communes spécifiques,EPCI spécifiques,Départements spécifiques,Régions spécifiques
          Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job,#{expert.id},Team 1,team@team.com,09 87 65 43 21,,"200041499, 200041762",,
        CSV
        is_expected.to eq csv
      end
    end

    context "With specific departments" do
      let(:territorial_zones) do
  [
    create(:territorial_zone, :departement, code: "22"),
    create(:territorial_zone, :departement, code: "72")
  ]
end

      it do
        csv = <<~CSV
          Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction,Id de l’équipe,Nom de l’équipe,Email de l’équipe,Téléphone de l’équipe,Communes spécifiques,EPCI spécifiques,Départements spécifiques,Régions spécifiques
          Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job,#{expert.id},Team 1,team@team.com,09 87 65 43 21,,,"22, 72",
        CSV
        is_expected.to eq csv
      end
    end

    context "With specific regions" do
      let(:territorial_zones) do
        [
          create(:territorial_zone, :region, code: "53"),
          create(:territorial_zone, :region, code: "11")
        ]
      end

      it do
        csv = <<~CSV
          Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction,Id de l’équipe,Nom de l’équipe,Email de l’équipe,Téléphone de l’équipe,Communes spécifiques,EPCI spécifiques,Départements spécifiques,Régions spécifiques
          Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job,#{expert.id},Team 1,team@team.com,09 87 65 43 21,,,,"53, 11"
        CSV
        is_expected.to eq csv
      end
    end
  end

  describe 'with subjects' do
    let(:theme) { create :theme, label: 'Test Theme' }
    let(:the_subject) { create :subject, theme: theme, label: 'Test Subject' }
    let(:institution_subject) { create :institution_subject, institution: institution, subject: the_subject, description: 'Description for institution' }
    let!(:expert_subject) { create :expert_subject, expert: expert, institution_subject: institution_subject, intervention_criteria: 'Intervention criteria' }
    let(:expert) { create :expert, antenne: antenne, users: [user] }

    subject do
      institution.reload
      User.all.export_csv(institutions_subjects: institution.institutions_subjects).csv
    end

    it do
      csv = <<~CSV
        Institution,Antenne,Prénom et nom,Email,Téléphone,Fonction,Test Subject
        Test Institution,Test Antenne,User 1,user@user.com,01 23 45 67 89,User Job,Intervention criteria
      CSV
      is_expected.to eq csv
    end
  end
end
