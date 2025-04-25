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

    describe 'correct_subject_answers' do
      let(:pde_subject) { create :subject }
      let(:landing_subject) { create :landing_subject, subject: pde_subject }
      let(:solicitation) { create :solicitation, status: 'step_description', landing_subject: landing_subject }

      before { solicitation.update(status: 'in_progress') }

      context 'with no subject_question' do
        it { expect(solicitation).to be_valid }
      end

      context 'with subject_questions' do
        let!(:subject_question_01) { create :subject_question, subject: pde_subject }
        let!(:subject_question_02) { create :subject_question, subject: pde_subject }

        context 'with missing subject_answers' do
          it { expect(solicitation).not_to be_valid }
        end

        context 'with correct subject_answers' do
          let!(:subject_answer_01) { create :solicitation_subject_answer, subject_questionable: solicitation, subject_question: subject_question_01 }
          let!(:subject_answer_02) { create :solicitation_subject_answer, subject_questionable: solicitation, subject_question: subject_question_02 }

          it { expect(solicitation).to be_valid }
        end

        context 'with incorrect subject_answers' do
          let!(:subject_answer_01) { create :solicitation_subject_answer, subject_questionable: solicitation, subject_question: create(:subject_question) }
          let!(:subject_answer_02) { create :solicitation_subject_answer, subject_questionable: solicitation, subject_question: create(:subject_question) }

          it { expect(solicitation).not_to be_valid }
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'set_cooperation' do
      subject { solicitation.set_cooperation }

      context 'with cooperation from a landing page' do
        let(:cooperation) { create :cooperation }
        let(:landing) { build :landing, cooperation: cooperation }
        let(:solicitation) { create :solicitation, landing: landing }

        it { is_expected.to eq cooperation }
      end

      context 'with a cooperation mtm_campaign in the query_params' do
        let!(:cooperation) { create :cooperation, mtm_campaign: 'une-campagne' }
        let(:solicitation) { create :solicitation, form_info: { mtm_campaign: 'une-campagne' } }

        it { is_expected.to eq cooperation }
      end

      context 'with entreprendre mtm_kwd in the query_params' do
        let!(:cooperation) { create :cooperation, mtm_campaign: 'entreprendre' }
        let(:solicitation) { create :solicitation, form_info: { mtm_kwd: 'F12345' } }

        it { is_expected.to eq cooperation }
      end

      context 'with no cooperation' do
        let(:landing) { build :landing, cooperation: nil }
        let(:solicitation) { create :solicitation, landing: landing, form_info: {} }

        it { is_expected.to be_nil }
      end

      context 'with random mtm_kwd' do
        let!(:cooperation) { create :cooperation, mtm_campaign: 'entreprendre' }
        let(:solicitation) { create :solicitation, form_info: { mtm_kwd: 'FrouFrou' } }

        it { is_expected.to be_nil }
      end

      context 'with missing campaign' do
        let!(:entreprendre_cooperation) { create :cooperation, mtm_campaign: 'entreprendre' }
        let!(:other_cooperation) { create :cooperation }
        let(:solicitation) { build :solicitation, form_info: { mtm_kwd: 'F12345' } }

        it { is_expected.to eq entreprendre_cooperation }

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

    describe 'AASM' do
      describe 'complete' do
        let(:email) { Faker::Internet.email }

        context 'with spam email' do
          let(:solicitation) { create :solicitation, status: :step_description, email: email }
          let!(:spam) { create :spam, email: email }

          before { solicitation.complete! }

          it 'cancel the solicitation' do
            expect(solicitation).to be_status_canceled
            expect(solicitation.badges.pluck(:title)).to include('Spam')
          end
        end

        context 'with non spam email' do
          let(:solicitation) { create :solicitation, status: :step_description }

          before { solicitation.complete! }

          it 'does not cancel the solicitation' do
            expect(solicitation).to be_status_in_progress
            expect(solicitation.badges).to be_empty
          end
        end
      end
    end

    describe 'set_provenance_detail' do
      subject { solicitation.provenance_detail }

      context 'with nothing' do
        let(:solicitation) { create :solicitation }

        it { is_expected.to be_nil }
      end

      context 'with entreprendre cooperation' do
        let(:cooperation) { create :cooperation, id: 1, mtm_campaign: 'entreprendre' }
        let(:solicitation) { create :solicitation, cooperation: cooperation, form_info: { mtm_kwd: 'F12345', origin_title: 'Titre aide', origin_url: 'https://www.partner.com/formulaire' } }

        it { is_expected.to eq 'F12345' }
      end

      context 'with les_aides cooperation' do
        let(:cooperation) { create :cooperation, id: 3 }
        let(:solicitation) { create :solicitation, cooperation: cooperation, form_info: { mtm_kwd: 'lala', origin_title: 'Titre aide', origin_url: 'https://www.partner.com/formulaire' } }

        it { is_expected.to eq 'Titre aide' }
      end

      context 'with MTEE cooperation' do
        let(:cooperation) { create :cooperation, id: 4 }
        let(:solicitation) { create :solicitation, cooperation: cooperation, form_info: { mtm_kwd: 'lala', origin_title: 'Titre aide', origin_url: "https://mission-transition-ecologique.beta.gouv.fr/aide-entreprise/diagnostic-transition-energetique" } }

        it { is_expected.to eq 'aide-entreprise/diagnostic-transition-energetique' }
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

  describe "from_intermediary?" do
    let!(:solicitation) { create :solicitation }

    subject { solicitation.from_intermediary? }

    context 'with facility' do
      let!(:diagnosis) { create :diagnosis, solicitation: solicitation, facility: facility }
      let!(:facility) { create :facility, naf_code: naf_code }

      context 'with intermediary' do
        let(:naf_code) { '70.22Z' }

        it { is_expected.to be true }
      end

      context 'without intermediary' do
        let(:naf_code) { '62.02A' }

        it { is_expected.to be false }
      end

      context 'without nafcode' do
        let(:naf_code) { nil }

        it { is_expected.to be false }
      end
    end

    context 'without facility' do
      it { is_expected.to be false }
    end
  end

  describe "similar_abandonned_solicitations" do
    let(:landing_subject) { create :landing_subject, subject: sol_subject }
    let(:solicitation) { create :solicitation, email: 'hedy@lamarr.bzh', siret: '41816609600069' }
    let!(:old_solicitation) { create :solicitation, email: email, siret: siret, status: status }
    let(:has_similar_abandonned_solicitations) { solicitation.has_similar_abandonned_solicitations? }

    subject { solicitation.similar_abandonned_solicitations }

    context 'same email abandonned' do
      let(:email) { 'hedy@lamarr.bzh' }
      let(:siret) { '71816609600054' }
      let(:status) { :canceled }

      context '1 solicitation' do
        it { is_expected.to contain_exactly(old_solicitation) }
        it { expect(has_similar_abandonned_solicitations).to be false }
      end

      context 'many solicitations' do
        before do
          3.times { create :solicitation, email: email, siret: siret, status: status }
        end

        it { expect(has_similar_abandonned_solicitations).to be true }
      end
    end

    context 'same siret abandonned' do
      let(:email) { 'other@mail.com' }
      let(:siret) { '41816609600069' }
      let(:status) { :canceled }

      it { is_expected.to contain_exactly(old_solicitation) }
      it { expect(has_similar_abandonned_solicitations).to be false }
    end

    context 'same siret not abandonned' do
      let(:email) { 'hedy@lamarr.bzh' }
      let(:siret) { '41816609600069' }
      let(:status) { :processed }

      it { is_expected.to be_empty }
      it { expect(has_similar_abandonned_solicitations).to be false }
    end
  end

  describe "not_sas" do
    subject { solicitation.not_sas? }

    context 'solicitation with diagnosis' do
      let(:other_landing_subject) { create :landing_subject, subject: other_subject }
      let(:formation_subject) { create :subject, id: 261 }
      let(:other_subject) { create :subject }
      let(:sas_company) { create :company, legal_form_code: '5710' }
      let(:non_sas_company) { create :company, legal_form_code: '6533' }
      let(:solicitation) { create :solicitation, landing_subject: landing_subject }
      let!(:diagnosis) { create :diagnosis, company: company, solicitation: solicitation }

      describe 'with subject and not SAS' do
        let(:landing_subject) { create :landing_subject, subject: formation_subject }
        let(:company) { non_sas_company }

        it { is_expected.to be true }
      end

      describe 'with subject an SAS' do
        let(:landing_subject) { create :landing_subject, subject: formation_subject }
        let(:company) { sas_company }

        it { is_expected.to be false }
      end

      describe 'for others subjects' do
        let(:landing_subject) { other_landing_subject }
        let(:company) { sas_company }

        it { is_expected.to be false }
      end

      context 'old solicitation without landing subject' do
        let(:solicitation) { build :solicitation, landing_subject: nil }
        let(:company) { sas_company }

        it { is_expected.to be false }
      end
    end

    context 'solicitation without diagnosis' do
      let(:solicitation) { create :solicitation }

      it { is_expected.to be false }
    end
  end

  describe '#provenance_title' do
    subject { solicitation.provenance_title }

    context 'intern' do
      let(:solicitation) { create :solicitation, landing: landing }
      let(:landing) { create :landing, title: 'Landing title', slug: 'landing-title', integration: :intern }

      it { is_expected.to be_nil }
    end

    context 'iframe' do
      let(:cooperation) { create :cooperation, root_url: 'https://www.partner.com' }
      let(:solicitation) { create :solicitation, landing: landing }
      let(:landing) { create :landing, title: 'Landing title', slug: 'landing-title', integration: :iframe, cooperation: cooperation }

      it { is_expected.to eq 'landing-title' }
    end

    context 'api' do
      let(:cooperation) { create :cooperation, root_url: 'https://www.partner.com' }
      let(:solicitation) { create :solicitation, landing: landing, origin_url: 'https://www.partner.com' }
      let(:landing) { create :landing, title: 'Landing title', slug: 'landing-title', integration: :api, cooperation: cooperation }

      it { is_expected.to eq 'https://www.partner.com' }
    end

    context 'campaign' do
      let(:solicitation) { create :solicitation, mtm_campaign: 'googleads-19133358444', mtm_kwd: '639333221110-opco', landing: landing }
      let(:landing) { create :landing, title: 'Landing title', slug: 'landing-title', integration: :intern }

      it { is_expected.to eq 'googleads-19133358444' }
    end
  end

  describe "#provenance_detail" do
    subject { solicitation.provenance_detail }

    context 'from campaign' do
      let(:solicitation) { create :solicitation, mtm_campaign: 'googleads-19133358444', mtm_kwd: '639333221110-opco' }

      it { is_expected.to eq '639333221110-opco' }
    end

    context 'with origin_title' do
      let(:solicitation) { create :solicitation, origin_title: 'origin title' }

      it { is_expected.to eq 'origin title' }
    end

    context 'with origin_url' do
      let(:solicitation) { create :solicitation, origin_url: 'https://www.partner.com/formulaire' }

      it { is_expected.to eq 'https://www.partner.com/formulaire' }
    end
  end

  describe '#provenance_title_sanitized' do
    subject { solicitation.provenance_title_sanitized }

    context 'from Google ads' do
      let(:solicitation) { create :solicitation, mtm_campaign: 'googleads-19133358444', mtm_kwd: '639333221110-opco' }

      it { is_expected.to eq 'googleads' }
    end

    context 'from other campaign' do
      let(:solicitation) { create :solicitation, mtm_campaign: 'campagne-123', mtm_kwd: 'campagne fine' }

      it { is_expected.to eq 'campagne-123' }
    end
  end

  describe 'may_prepare_diagnosis' do
    subject(:may_prepare_diagnosis) { solicitation.may_prepare_diagnosis? }

    context 'with_siret' do
      let(:solicitation) { create :solicitation }

      it { is_expected.to be true }
    end

    context 'with_location' do
      let(:solicitation) { create :solicitation, siret: nil, location: "Matignon" }
      let(:api_url) { "https://api-adresse.data.gouv.fr/search/?q=matignon&type=municipality" }

      before do
        stub_request(:get, api_url).to_return(
          body: file_fixture('api_adresse_search_municipality.json')
        )
      end

      it { is_expected.to be false }
    end

    context 'without_location' do
      let(:solicitation) { create :solicitation, siret: nil }

      it { is_expected.to be false }
    end

    context 'with email in spam list' do
      let(:email) { Faker::Internet.email }
      let(:solicitation) { create :solicitation, email: email }
      let!(:spawn) { create :spam, email: email }

      it { is_expected.to be false }
    end
  end

  describe 'prepare_diagnosis_errors_to_s' do
    let(:solicitation) { create :solicitation, prepare_diagnosis_errors: errors }

    subject(:prepare_diagnosis_errors_to_s) { solicitation.prepare_diagnosis_errors_to_s }

    context 'model error' do
      let(:errors) { { "matches" => [{ "error" => "preselected_institution_has_no_relevant_experts" }] } }

      it { is_expected.to eq ['Mises en relation : aucun expert de l’institution présélectionnée ne peut prendre en charge cette entreprise.'] }
    end

    context 'standard error' do
      let(:errors) { { "basic_errors" => I18n.t('api_requests.invalid_siret_or_siren') } }

      it { is_expected.to eq ['L’identifiant (siret ou siren) est invalide'] }
    end

    context 'major error' do
      let(:errors) { { "major_api_error" => { "api-apientreprise-entreprise-base" => "Caramba !" } } }

      it { is_expected.to eq ['Api Entreprise (entreprise) : Caramba !'] }
    end

    context 'unreachable_api error' do
      let(:errors) { { "unreachable_apis" => { "api-rne-companies-base" => "Caramba !" } } }

      it { is_expected.to eq ['Api RNE (entreprises) : Caramba !'] }
    end

    context 'standard_api_errors' do
      let(:errors) { { "standard_api_errors" => { "api-rne-companies-base" => "Caramba !" } } }

      it { is_expected.to eq [] }
    end
  end

  describe 'mark_as_spam' do
    let(:solicitation) { create(:solicitation, email: email, status: 'in_progress') }
    let(:email) { Faker::Internet.email }

    context 'when email is not already marked as spam' do
      before { solicitation.mark_as_spam }

      it 'creates Spam record and cancels the solicitation' do
        expect(Spam.count).to eq 1
        expect(Spam.first.email).to eq email
        expect(solicitation).to be_canceled
        expect(solicitation.badges.pluck(:title)).to include('Spam')
      end
    end

    context 'when email is already marked as spam' do
      let!(:spam) { create(:spam, email: email) }

      before { solicitation.mark_as_spam }

      it 'cancels the solicitation' do
        expect(Spam.count).to eq 1
        expect(solicitation).to be_canceled
        expect(solicitation.badges.pluck(:title)).to include('Spam')
      end
    end
  end

  describe 'final_subject_title' do
    subject(:final_subject_title) { solicitation.final_subject_title }

    let(:subject_1) { create :subject, label: 'Subject 1 label' }
    let(:landing_subject) { create :landing_subject, title: 'Landing Subject Title', subject: subject_1 }
    let(:solicitation) { create :solicitation, landing_subject: landing_subject }

    context 'with only landing_subject' do
      it { is_expected.to eq 'Landing Subject Title' }
    end

    context 'with needs' do
      let(:subject_2) { create :subject, label: 'Subject 2 label' }
      let!(:need) { create :need, subject: subject_2, diagnosis: create(:diagnosis, solicitation: solicitation) }

      it { is_expected.to eq 'Subject 2 label' }
    end
  end
end
