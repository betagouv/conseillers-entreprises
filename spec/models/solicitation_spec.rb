# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solicitation, type: :model do
  describe 'associations' do
    it { is_expected.to have_one :diagnosis }
  end

  describe 'validations' do
    subject { described_class.new }

    it { is_expected.to validate_presence_of :landing }
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :phone_number }
    it { is_expected.to validate_presence_of :email }

    context 'in_progress' do
      subject { described_class.new(status: :in_progress) }

      it { is_expected.to validate_presence_of :description }
    end
  end

  describe 'callbacks' do
    describe 'set_institution_from_landing' do
      subject { solicitation.institution }

      context 'with institution from a landing page' do
        let(:institution) { build :institution }
        let(:landing) { build :landing, institution: institution }
        let(:solicitation) { create :solicitation, landing: landing }

        it { is_expected.to eq institution }
      end

      context 'with a solicitation slug in the query_params' do
        let(:institution) { create :institution }
        let(:solicitation) { create :solicitation, form_info: { institution: institution.slug } }

        it { is_expected.to eq institution }
      end

      context 'with no institution' do
        let(:landing) { build :landing, institution: nil }
        let(:solicitation) { create :solicitation, landing: landing, form_info: {} }

        it { is_expected.to be_nil }
      end
    end

    describe 'format_solicitation' do
      let(:token) { '1234' }
      let(:siret) { '41816609600069' }
      let(:email) { 'contact..machin@truc.fr' }

      context 'with all fields to be formatted' do
        let(:api_url) { "https://entreprise.api.gouv.fr/v2/etablissements/#{siret}?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }
        let(:solicitation) { create :solicitation, siret: siret, code_region: nil, email: email }

        before do
          ENV['API_ENTREPRISE_TOKEN'] = token
          stub_request(:get, api_url).to_return(
            body: file_fixture('api_entreprise_get_etablissement.json')
          )
        end

        it 'formats correctly fields' do
          expect(solicitation.code_region).to eq(11)
          expect(solicitation.siret).to eq('41816609600069')
          expect(solicitation.email).to eq('contact.machin@truc.fr')
        end
      end

      context 'with already set code_region' do
        let(:solicitation) { create :solicitation, siret: siret, code_region: 11, email: email }

        it 'formats correctly fields' do
          expect(solicitation.code_region).to eq(11)
          expect(solicitation.siret).to eq('41816609600069')
          expect(solicitation.email).to eq('contact.machin@truc.fr')
        end
      end

      context 'with failing siret' do
        let(:solicitation) { create :solicitation, siret: "lalala", code_region: nil, email: email }

        it 'doesnt set code_region' do
          expect(solicitation.code_region).to be_nil
          expect(solicitation.siret).to eq('lalala')
          expect(solicitation.email).to eq('contact.machin@truc.fr')
        end
      end
    end

    describe 'set_siret_and_region' do
      let(:token) { '1234' }
      let(:siret) { '41816609600069' }

      context 'with valid siret' do
        let(:api_url) { "https://entreprise.api.gouv.fr/v2/etablissements/#{siret}?context=PlaceDesEntreprises&non_diffusables=true&object=PlaceDesEntreprises&recipient=PlaceDesEntreprises&token=1234" }
        let(:solicitation) { create :solicitation, siret: siret, code_region: nil }

        before do
          ENV['API_ENTREPRISE_TOKEN'] = token
          stub_request(:get, api_url).to_return(
            body: file_fixture('api_entreprise_get_etablissement.json')
          )
        end

        it 'sets correctly siret and code_region' do
          expect(solicitation.code_region).to eq(11)
          expect(solicitation.siret).to eq('41816609600069')
          expect(solicitation.created_in_deployed_region).to be true
        end
      end

      context 'with valid siren' do
        let(:siren) { siret[0,9] }
        let(:api_url) { "https://entreprise.data.gouv.fr/api/sirene/v1/siren/#{siren}" }
        let(:solicitation) { create :solicitation, siret: siren, code_region: nil }

        before do
          ENV['API_ENTREPRISE_TOKEN'] = token
          stub_request(:get, api_url).to_return(
            body: file_fixture('entreprise_data_gouv_siren.json')
          )
        end

        it 'sets correctly siret and code_region' do
          expect(solicitation.code_region).to eq(11)
          expect(solicitation.siret).to eq('41816609600069')
          expect(solicitation.created_in_deployed_region).to be true
        end
      end

      context 'with wrong siret' do
        let(:solicitation) { create :solicitation, siret: "lalala", code_region: nil }

        it 'doesnt set code_region' do
          expect(solicitation.code_region).to be_nil
          expect(solicitation.siret).to eq('lalala')
          expect(solicitation.created_in_deployed_region).to be false
        end
      end
    end
  end

  describe '#preselected_subject' do
    let(:solicitation) { create :solicitation, landing_subject: landing_subject }

    subject { solicitation.preselected_subject }

    context 'subject is known' do
      let(:pde_subject) { create :subject }
      let(:landing_subject) { create :landing_subject, subject: pde_subject }

      it { is_expected.to eq pde_subject }
    end

    context 'subject is unknown' do
      let(:landing_subject) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '#have_badge' do
    let(:badge) { create :badge, title: 'test' }
    let(:solicitation) { create :solicitation, badges: [badge] }
    let!(:solicitation_without_badge) { create :solicitation }

    subject { described_class.have_badge('test') }

    it { is_expected.to match_array [solicitation] }
  end

  describe '#have_landing_subject' do
    let(:landing_subject) { create :landing_subject, slug: 'subject-slug' }
    let(:solicitation) { create :solicitation, landing_subject: landing_subject }
    let(:solicitation_without_subject) { create :solicitation }

    subject { described_class.have_landing_subject('subjec') }

    it { is_expected.to match_array [solicitation] }
  end

  describe '#have_landing_theme' do
    let(:landing_theme) { create :landing_theme, slug: 'theme-slug' }
    let(:landing_subject) { create :landing_subject, landing_theme: landing_theme }
    let(:solicitation) { create :solicitation, landing_subject: landing_subject }
    let(:solicitation_without_subject) { create :solicitation }

    subject { described_class.have_landing_theme('them') }

    it { is_expected.to match_array [solicitation] }
  end

  describe '#description_contains' do
    let(:solicitation) { create :solicitation, description: 'Description de test' }
    let!(:solicitation2) { create :solicitation, description: 'Une autre description' }

    subject { described_class.description_contains('test') }

    it { is_expected.to match_array [solicitation] }
  end

  describe '#have_landing' do
    let(:landing) { create :landing, slug: 'landing-slug' }
    let(:solicitation) { create :solicitation, landing: landing }
    let!(:solicitation_other_landing) { create :solicitation }

    subject { described_class.have_landing('anding-slu') }

    it { is_expected.to match_array [solicitation] }
  end

  describe '#name_contains' do
    let(:solicitation) { create :solicitation, full_name: 'Pink Floyd' }
    let!(:solicitation2) { create :solicitation, full_name: 'Edith Piaf' }

    subject { described_class.name_contains('Pink') }

    it { is_expected.to match_array [solicitation] }
  end

  describe '#email_contains' do
    let(:solicitation) { create :solicitation, email: 'kingju@wanadoo.fr' }
    let!(:solicitation2) { create :solicitation, email: 'edith@piaf.fr' }

    subject { described_class.email_contains('kingju') }

    it { is_expected.to match_array [solicitation] }
  end

  describe "#by_possible_region" do
    let(:territory1) { create :territory, :region, code_region: Territory.deployed_codes_regions.first }
    # - solicitation avec facility dans une region déployé
    let!(:solicitation1) { create :solicitation, :with_diagnosis, code_region: territory1.code_region }
    # - solicitation avec facility dans territoire non déployé
    let!(:solicitation2) { create :solicitation, :with_diagnosis, code_region: 22 }
    # - solicitation inclassables (sans analyse, sans région...)
    let!(:solicitation_without_diagnosis) { create :solicitation, siret: 'wrong siret', code_region: nil }
    let!(:solicitation_with_diagnosis_no_region) { create :solicitation, :with_diagnosis, siret: 'wrong siret', code_region: nil }

    before {
      territory1.communes = [solicitation1.diagnosis.facility.commune]
    }

    subject { described_class.by_possible_region(possible_region) }

    context 'filter by existing territory' do
      let(:possible_region) { territory1.id }

      it { is_expected.to match_array [solicitation1] }
    end

    context 'filter by diagnoses problem' do
      let(:possible_region) { 'uncategorisable' }

      it { is_expected.to match_array [solicitation_without_diagnosis, solicitation_with_diagnosis_no_region] }
    end

    context 'filter by out_of_deployed_territories' do
      let(:possible_region) { 'out_of_deployed_territories' }

      it { is_expected.to match_array [solicitation2] }
    end
  end

  describe "recent_matched_solicitations" do
    let(:landing_subject) { create :landing_subject }
    let(:siret) { '13000601800019' }
    let(:email) { 'hubertine@example.com' }

    let!(:parent_siret_solicitation) {
      create :solicitation,
             siret: siret,
             landing_subject: landing_subject,
             created_at: 2.weeks.ago,
             status: 'processed'
    }

    let!(:parent_email_solicitation) {
      create :solicitation,
             email: email,
             landing_subject: landing_subject,
             created_at: 2.weeks.ago,
             status: 'processed'
    }

    let!(:other_siret_solicitation) {
      create :solicitation,
             siret: '98765432100099',
             landing_subject: landing_subject,
             created_at: 2.weeks.ago,
             status: 'processed'
    }

    let!(:too_old_solicitation) {
      create :solicitation,
             email: email,
             siret: siret,
             landing_subject: landing_subject,
             created_at: 6.weeks.ago,
             status: 'processed'
    }

    let!(:other_subject_solicitation) {
      create :solicitation,
             email: email,
             siret: siret,
             landing_subject: create(:landing_subject),
             created_at: 2.weeks.ago,
             status: 'processed'
    }

    let!(:no_match_solicitation) {
      create :solicitation,
             email: email,
             siret: siret,
             landing_subject: landing_subject,
             created_at: 2.weeks.ago
    }

    let!(:child_solicitation) {
      create :solicitation,
             siret: siret,
             email: email,
             landing_subject: landing_subject
    }

    it 'displays only parent_solicitations' do
      expect(child_solicitation.recent_matched_solicitations).to match_array([parent_siret_solicitation, parent_email_solicitation])
    end
  end

  describe "doublon_solicitations" do
    let(:siret) { '13000601800019' }
    let(:email) { 'hubertine@example.com' }

    let!(:same_siret_solicitation) {
      create :solicitation,
             siret: siret
    }

    let!(:same_email_solicitation) {
      create :solicitation,
             email: email
    }

    let!(:same_siret_with_matched_solicitation) {
      create :solicitation,
             siret: siret,
             status: :processed,
             diagnosis: create(:diagnosis_completed)
    }

    let!(:other_siret_solicitation) {
      create :solicitation,
             siret: '98765432100099'
    }

    let!(:solicitation) {
      create :solicitation,
             siret: siret,
             email: email
    }

    it 'displays only doublon solicitations' do
      expect(solicitation.doublon_solicitations).to match_array([same_siret_solicitation, same_email_solicitation])
    end
  end
end
