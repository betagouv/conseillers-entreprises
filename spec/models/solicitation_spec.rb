# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solicitation do
  describe 'associations' do
    it { is_expected.to have_one :diagnosis }
  end

  describe 'validations' do
    subject { described_class.new }

    it { is_expected.to validate_presence_of :landing }
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :phone_number }
    it { is_expected.to validate_presence_of :email }

    context 'validate_description' do
      let(:landing_subject) { create :landing_subject, description_prefill: "Préremplissage" }
      let(:solicitation) { create :solicitation, status: 'step_description', description: description, landing_subject: landing_subject }

      subject { build :solicitation, status: 'in_progress', description: description, landing_subject: landing_subject }

      context 'with empty description' do
        let(:description) { ' ' }

        it { is_expected.not_to be_valid }
      end

      context 'with non completed description' do
        let(:description) { landing_subject.description_prefill }

        it { is_expected.not_to be_valid }
      end

      context 'with edited description' do
        let(:description) { 'edited description' }

        it { is_expected.to be_valid }
      end
    end

    describe 'validate siret' do

      describe 'moment of validation' do
        let(:subject_with_siret) { create :landing_subject, requires_siret: true }
        let(:subject_without_siret) { create :landing_subject, requires_siret: false }
        # solicitation à l'étape contact ko
        let(:contact_solicitation) { build :solicitation, status: :step_contact, landing_subject: subject_with_siret }
        # solicitation à l'étape company ko
        let(:company_solicitation) { build :solicitation, status: :step_company, landing_subject: subject_with_siret }
        # solicitation à l'étape description avec siret obligatoire ok
        let(:description_solicitation_with_siret) { build :solicitation, status: :step_description, landing_subject: subject_with_siret }
        # solicitation à l'étape description sans siret obligatoire ko
        let(:description_solicitation_without_siret) { build :solicitation, status: :step_description, landing_subject: subject_without_siret }

        it 'check presence of siret' do
          expect(contact_solicitation).not_to validate_presence_of :siret
          expect(company_solicitation).not_to validate_presence_of :siret
          expect(description_solicitation_with_siret).to validate_presence_of :siret
          expect(description_solicitation_without_siret).not_to validate_presence_of :siret
        end
      end

      describe 'full validation' do
        let(:solicitation) { create :solicitation, status: 'step_company', siret: siret, code_region: nil }

        describe 'with no siret' do
          let(:siret) { nil }

          before { solicitation.update(status: 'step_description') }

          it { expect(solicitation).not_to be_valid }
        end

        describe 'with malformed siret' do
          let(:siret) { '123456789 00010' }

          before { solicitation.update(status: 'step_description') }

          it { expect(solicitation).not_to be_valid }
        end

        describe 'with valid siret' do
          let(:token) { '1234' }
          let(:api_url) { "https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/#{siret}?context=PlaceDesEntreprises&object=PlaceDesEntreprises&recipient=13002526500013" }

          before do
            ENV['API_ENTREPRISE_TOKEN'] = token
            stub_request(:get, api_url).to_return(
              body: api_body
            )
            solicitation.update(status: 'step_description')
          end

          describe 'with foreign siret' do
            let(:siret) { '84784706800016' }
            let(:api_body) do
  { "data" =>
    { "siret" => "84784706800016",
      "adresse" =>
      { "status_diffusion" => "diffusible",
        "code_postal" => nil,
        "libelle_commune" => nil,
        "libelle_commune_etranger" => "1260 NYON",
        "code_commune" => nil,
        "code_pays_etranger" => "99140",
        "libelle_pays_etranger" => "SUISSE",
      }
    },
    "links" => {}, "meta" => {}
  }.to_json
end

            it { expect(solicitation).not_to be_valid }
          end

          describe 'with correct french siret' do
            let(:siret) { '41816609600069' }
            let(:api_body) { file_fixture('api_entreprise_etablissement.json') }

            it do
              expect(solicitation).to be_valid
              expect(solicitation.code_region).to eq(11)
            end
          end

        end
      end
    end

    describe 'correct_institution_filters' do
      let(:pde_subject) { create :subject }
      let(:landing_subject) { create :landing_subject, subject: pde_subject }
      let(:solicitation) { create :solicitation, status: 'step_description', landing_subject: landing_subject }

      before { solicitation.update(status: 'in_progress') }

      context 'with no additional_subject_question' do
        it { expect(solicitation).to be_valid }
      end

      context 'with additional_subject_questions' do
        let!(:additional_subject_question_01) { create :additional_subject_question, subject: pde_subject }
        let!(:additional_subject_question_02) { create :additional_subject_question, subject: pde_subject }

        context 'with missing institution_filters' do
          it { expect(solicitation).not_to be_valid }
        end

        context 'with correct institution_filters' do
          let!(:institution_filter_01) { create :institution_filter, institution_filtrable: solicitation, additional_subject_question: additional_subject_question_01 }
          let!(:institution_filter_02) { create :institution_filter, institution_filtrable: solicitation, additional_subject_question: additional_subject_question_02 }

          it { expect(solicitation).to be_valid }
        end

        context 'with incorrect institution_filters' do
          let!(:institution_filter_01) { create :institution_filter, institution_filtrable: solicitation, additional_subject_question: create(:additional_subject_question) }
          let!(:institution_filter_02) { create :institution_filter, institution_filtrable: solicitation, additional_subject_question: create(:additional_subject_question) }

          it { expect(solicitation).not_to be_valid }
        end
      end
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
      let(:siret) { '41816609600069' }
      let(:email) { 'contact..machin@truc.fr' }

      context 'with all fields to be formatted' do
        let(:solicitation) { create :solicitation, email: email, status: :step_description }

        before do
          solicitation.complete
        end

        it 'formats correctly fields' do
          expect(solicitation.email).to eq('contact.machin@truc.fr')
        end
      end

      context 'with already set code_region' do
        let(:solicitation) { create :solicitation, siret: siret, code_region: 11, email: email, status: :step_description }

        before { solicitation.complete }

        it 'formats correctly fields' do
          expect(solicitation.code_region).to eq(11)
          expect(solicitation.siret).to eq('41816609600069')
          expect(solicitation.email).to eq('contact.machin@truc.fr')
        end
      end
    end
  end

  describe '#preselected_subject' do
    subject { solicitation.preselected_subject }

    context 'subject is known' do
      let(:pde_subject) { create :subject }
      let(:landing_subject) { create :landing_subject, subject: pde_subject }
      let(:solicitation) { create :solicitation, landing_subject: landing_subject }

      it { is_expected.to eq pde_subject }
    end

    context 'subject is unknown' do
      let(:solicitation) { create :solicitation, created_at: "20201030".to_date, landing_subject: nil }

      it { is_expected.to be_nil }
    end
  end

  describe '#have_badge' do
    let(:badge) { create :badge, title: 'test' }
    let(:solicitation) { create :solicitation, badges: [badge] }
    let!(:solicitation_without_badge) { create :solicitation }

    subject { described_class.have_badge('test') }

    it { is_expected.to contain_exactly(solicitation) }
  end

  describe '#have_landing_subject' do
    let(:landing_subject) { create :landing_subject, slug: 'subject-slug' }
    let(:solicitation) { create :solicitation, landing_subject: landing_subject }
    let(:solicitation_without_subject) { create :solicitation }

    subject { described_class.have_landing_subject('subjec') }

    it { is_expected.to contain_exactly(solicitation) }
  end

  describe '#have_landing_theme' do
    let(:landing_theme) { create :landing_theme, slug: 'theme-slug' }
    let(:landing_subject) { create :landing_subject, landing_theme: landing_theme }
    let(:solicitation) { create :solicitation, landing_subject: landing_subject }
    let(:solicitation_without_subject) { create :solicitation }

    subject { described_class.have_landing_theme('them') }

    it { is_expected.to contain_exactly(solicitation) }
  end

  describe '#description_cont' do
    let(:solicitation) { create :solicitation, description: 'Description de test' }
    let!(:solicitation2) { create :solicitation, description: 'Une autre description' }

    subject { described_class.description_cont('test') }

    it { is_expected.to contain_exactly(solicitation) }
  end

  describe '#have_landing' do
    let(:landing) { create :landing, slug: 'landing-slug' }
    let(:solicitation) { create :solicitation, landing: landing }
    let!(:solicitation_other_landing) { create :solicitation }

    subject { described_class.have_landing('anding-slu') }

    it { is_expected.to contain_exactly(solicitation) }
  end

  describe '#name_cont' do
    let(:solicitation) { create :solicitation, full_name: 'Pink Floyd' }
    let!(:solicitation2) { create :solicitation, full_name: 'Edith Piaf' }

    subject { described_class.name_cont('Pink') }

    it { is_expected.to contain_exactly(solicitation) }
  end

  describe '#email_cont' do
    let(:solicitation) { create :solicitation, email: 'kingju@wanadoo.fr' }
    let!(:solicitation2) { create :solicitation, email: 'edith@piaf.fr' }

    subject { described_class.email_cont('kingju') }

    it { is_expected.to contain_exactly(solicitation) }
  end

  describe '#siret_cont' do
    let(:solicitation) { create :solicitation, siret: '11000101300017' }
    let!(:solicitation2) { create :solicitation, siret: '89233420200017' }

    subject { described_class.siret_cont('110001013') }

    it { is_expected.to contain_exactly(solicitation) }
  end

  describe "#by_possible_region" do
    let(:territory1) { Territory.regions.first }
    # - solicitation avec facility dans une region déployé
    let!(:solicitation1) { create :solicitation, :with_diagnosis, code_region: territory1.code_region }
    # - solicitation avec facility dans territoire non déployé
    let!(:solicitation2) { create :solicitation, :with_diagnosis, code_region: 22 }
    # - solicitation inclassables (sans analyse, sans région...)
    let!(:solicitation_without_diagnosis) { create :solicitation, siret: 'wrong siret', code_region: nil }
    let!(:solicitation_with_diagnosis_no_region) { create :solicitation, :with_diagnosis, siret: 'wrong siret', code_region: nil }

    before do
      territory1.communes = [solicitation1.diagnosis.facility.commune]
    end

    subject { described_class.by_possible_region(possible_region) }

    context 'filter by existing territory' do
      let(:possible_region) { territory1.id }

      it { is_expected.to contain_exactly(solicitation1) }
    end

    context 'filter by diagnoses problem' do
      let(:possible_region) { 'uncategorisable' }

      it { is_expected.to contain_exactly(solicitation_without_diagnosis, solicitation_with_diagnosis_no_region) }
    end
  end

  describe "recent_matched_solicitations" do
    let(:landing_subject) { create :landing_subject }
    let(:siret) { '13000601800019' }
    let(:email) { 'hubertine@example.com' }

    let!(:parent_siret_solicitation) do
      create :solicitation,
             siret: siret,
             landing_subject: landing_subject,
             created_at: 2.weeks.ago,
             status: 'processed'
    end

    let!(:parent_email_solicitation) do
      create :solicitation,
             email: email,
             landing_subject: landing_subject,
             created_at: 2.weeks.ago,
             status: 'processed'
    end

    let!(:other_siret_solicitation) do
      create :solicitation,
             siret: '98765432100099',
             landing_subject: landing_subject,
             created_at: 2.weeks.ago,
             status: 'processed'
    end

    let!(:too_old_solicitation) do
      create :solicitation,
             email: email,
             siret: siret,
             landing_subject: landing_subject,
             created_at: 6.weeks.ago,
             status: 'processed'
    end

    let!(:other_subject_solicitation) do
      create :solicitation,
             email: email,
             siret: siret,
             landing_subject: create(:landing_subject),
             created_at: 2.weeks.ago,
             status: 'processed'
    end

    let!(:no_match_solicitation) do
      create :solicitation,
             email: email,
             siret: siret,
             landing_subject: landing_subject,
             created_at: 2.weeks.ago
    end

    let!(:child_solicitation) do
      create :solicitation,
             siret: siret,
             email: email,
             landing_subject: landing_subject
    end

    it 'displays only parent_solicitations' do
      expect(child_solicitation.recent_matched_solicitations).to contain_exactly(parent_siret_solicitation, parent_email_solicitation)
    end
  end

  describe "doublon_solicitations" do
    let(:siret) { '13000601800019' }
    let(:email) { 'hubertine@example.com' }

    let!(:same_siret_solicitation) do
      create :solicitation,
             siret: siret
    end

    let!(:same_email_solicitation) do
      create :solicitation,
             email: email
    end

    let!(:same_siret_with_matched_solicitation) do
      create :solicitation,
             siret: siret,
             status: :processed,
             diagnosis: create(:diagnosis_completed)
    end

    let!(:other_siret_solicitation) do
      create :solicitation,
             siret: '98765432100099'
    end

    let!(:solicitation) do
      create :solicitation,
             siret: siret,
             email: email
    end

    it 'displays only doublon solicitations' do
      expect(solicitation.doublon_solicitations).to contain_exactly(same_siret_solicitation, same_email_solicitation)
    end
  end

  describe 'from_no_register_company?' do
    let!(:facility) { create :facility, company: company }
    let(:solicitation) { create :solicitation, diagnosis: create(:diagnosis, facility: facility) }

    subject { solicitation.from_no_register_company? }

    context 'rcs and rm company' do
      let(:company) { create :company, inscrit_rcs: true, inscrit_rm: true }

      it { is_expected.to be false }
    end

    context 'rcs company' do
      let(:company) { create :company, inscrit_rcs: true, inscrit_rm: false }

      it { is_expected.to be false }
    end

    context 'rm company' do
      let(:company) { create :company, inscrit_rcs: false, inscrit_rm: true }

      it { is_expected.to be false }
    end

    context 'neither rcs nor rm company' do
      let(:company) { create :company, inscrit_rcs: false, inscrit_rm: false }

      it { is_expected.to be true }
    end

    context 'no company' do
      let(:solicitation) { create :solicitation }
      let(:company) { create :company }

      it { is_expected.to be false }
    end
  end

  describe "similar_abandonned_needs" do
    let(:landing_subject) { create :landing_subject, subject: sol_subject }
    let(:solicitation) { create :solicitation, email: email, siret: siret, landing_subject: landing_subject }
    let(:need_subject) { create :subject }

    let!(:need) do
      create :need_with_matches,
      subject: need_subject,
      diagnosis: create(:diagnosis,
        solicitation: create(:solicitation, email: 'need@mail.com'),
        facility: create(:facility, siret: '41816609600069'))
    end

    subject { solicitation.similar_abandonned_needs }

    context 'same company same subject abandonned' do
      let(:email) { 'need@mail.com' }
      let(:siret) { '41816609600069' }
      let(:sol_subject) { need_subject }

      before { need.reminders_actions.create(category: 'abandon') }

      it { is_expected.to contain_exactly(need) }
    end

    context 'same company same subject not abandonned' do
      let(:email) { 'need@mail.com' }
      let(:siret) { '41816609600069' }
      let(:sol_subject) { need_subject }

      it { is_expected.to be_empty }
    end

    context 'same company other subject' do
      let(:email) { 'need@mail.com' }
      let(:siret) { '41816609600069' }
      let(:sol_subject) { create :subject }

      before { need.reminders_actions.create(category: 'abandon') }

      it { is_expected.to be_empty }
    end
  end
end
