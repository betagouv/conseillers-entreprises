# frozen_string_literal: true

require 'rails_helper'
require 'api/api_entreprise/base'

RSpec.describe DiagnosisCreation do
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
  end

  describe 'prepare_diagnosis' do
    let(:user) { create :user }
    let(:api_url) { "https://api-adresse.data.gouv.fr/search/?q=matignon&type=municipality" }
    let(:some_params) do
      {
        advisor: user,
      facility_attributes: facility_attributes,
      solicitation: solicitation
      }
    end
    let(:facility_attributes) { { siret: solicitation.siret } }
    let!(:intermediary_result) { CreateDiagnosis::CreateOrUpdateDiagnosis.new(some_params, diagnosis) }

    before do
      allow(solicitation).to receive(:may_prepare_diagnosis?).and_return(true)
      # suivant le contexte, ce ne sont pas toujours les memes arguments qui sont envoyés
      allow(CreateDiagnosis::CreateOrUpdateDiagnosis).to receive(:new).with(some_params, diagnosis) { intermediary_result }
      allow(CreateDiagnosis::CreateOrUpdateDiagnosis).to receive(:new).with(some_params, nil) { intermediary_result }
      allow(intermediary_result).to receive(:call) { diagnosis }
      allow_any_instance_of(Diagnosis).to(receive(:prepare_needs_from_solicitation)) { prepare_needs }
      allow_any_instance_of(Diagnosis).to receive(:prepare_happened_on_from_solicitation)
      allow_any_instance_of(Diagnosis).to receive(:prepare_visitee_from_solicitation)
      allow_any_instance_of(Diagnosis).to receive(:prepare_matches_from_solicitation)
      stub_request(:get, api_url).to_return(
        body: file_fixture('api_adresse_search_municipality.json')
      )

      solicitation.prepare_diagnosis(user)
    end

    context 'solicitation with siret' do
      let(:solicitation) { create :solicitation }

      context 'all is well' do
        let(:diagnosis) { create :diagnosis, solicitation: solicitation, advisor: user }
        let(:prepare_needs) { [] }

        it do
          expect(solicitation.diagnosis).not_to be_nil
          expect(solicitation.prepare_diagnosis_errors).to be_empty
        end
      end

      context 'creation fails' do
        let(:diagnosis) { Diagnosis.create(facility: nil, advisor: user) }
        let(:prepare_needs) { [] }

        it do
          expect(solicitation.diagnosis).to be_nil
          expect(solicitation.prepare_diagnosis_errors.details).to eq({ facility: [{ error: :blank }] })
        end
      end

      context 'preparation fails' do
        let(:diagnosis) { create :diagnosis, solicitation: solicitation, advisor: user }
        let(:prepare_needs) { diagnosis.errors.add(:needs, :some_failure) }

        it do
          expect(solicitation.diagnosis).to be_nil
          expect(solicitation.prepare_diagnosis_errors.details).to eq({ needs: [{ error: :some_failure }] })
        end
      end
    end

    context 'solicitation without siret' do
      let(:location) { "matignon" }
      let(:solicitation) { create :solicitation, siret: nil, location: location }
      let(:facility_attributes) { { insee_code: '22143', company_attributes: { name: solicitation.full_name } } }

      context 'all is well' do
        let(:diagnosis) { create :diagnosis, solicitation: solicitation, advisor: user }
        let(:prepare_needs) { [] }

        it do
          expect(solicitation.diagnosis).not_to be_nil
          expect(solicitation.prepare_diagnosis_errors).to be_empty
        end
      end

      context 'creation fails' do
        let(:diagnosis) { Diagnosis.create(facility: nil, advisor: user) }
        let(:prepare_needs) { [] }

        it do
          expect(solicitation.diagnosis).to be_nil
          expect(solicitation.prepare_diagnosis_errors.details).to eq({ facility: [{ error: :blank }] })
        end
      end

      context 'preparation fails' do
        let(:diagnosis) { create :diagnosis, solicitation: solicitation, advisor: user }
        let(:prepare_needs) { diagnosis.errors.add(:needs, :some_failure) }

        it do
          expect(solicitation.diagnosis).to be_nil
          expect(solicitation.prepare_diagnosis_errors.details).to eq({ needs: [{ error: :some_failure }] })
        end
      end
    end
  end

  describe 'prepare_needs_from_solicitation' do
    let(:diagnosis) { create :diagnosis, solicitation: solicitation }
    let(:solicitation) { create :solicitation }

    before do
      allow(solicitation).to receive(:preselected_subject).and_return(pde_subject)
      diagnosis.prepare_needs_from_solicitation
    end

    context 'solicitation has preselected subjects' do
      let(:pde_subject) { create :subject }

      it 'creates needs' do
        expect(diagnosis.needs.count).to eq 1
      end
    end

    context 'solicitation has no preselected subjects' do
      let(:pde_subject) { nil }

      it 'sets an error' do
        expect(diagnosis.needs).to be_empty
        expect(diagnosis.errors.details).to eq({ needs: [{ error: :solicitation_has_no_preselected_subject }] })
      end
    end
  end

  describe 'prepare_visitee_from_solicitation' do
    let(:diagnosis) { create :diagnosis, solicitation: solicitation, visitee: nil }

    before do
      diagnosis.prepare_visitee_from_solicitation
    end

    context 'solicitation has all details' do
      let(:solicitation) { create :solicitation }

      it 'creates the visitee' do
        expect(diagnosis.visitee).to be_persisted
      end
    end

    context 'solicitation is missing some details' do
      let(:solicitation) { build :solicitation, full_name: nil }

      it 'sets an error' do
        expect(diagnosis.visitee).not_to be_persisted
        expect(diagnosis.errors.details).to eq({ :'visitee.full_name' => [{ error: :blank }] })
      end
    end
  end

  describe 'prepare_matches_from_solicitation' do
    let(:diagnosis) { create :diagnosis, solicitation: solicitation, step: 'needs' }
    let(:solicitation) { create :solicitation }
    let(:need) { create :need, diagnosis: diagnosis }
    let!(:other_need_subject) { create :subject, id: 59 }

    let!(:expert_subject) do
      create :expert_subject,
             institution_subject: create(:institution_subject, institution: institution, subject: the_subject),
             expert: create(:expert, communes: communes)
    end
    let(:institution) { create :institution }

    before do
      diagnosis.prepare_matches_from_solicitation
    end

    context 'there are relevant experts' do
      let(:the_subject) { need.subject }
      let(:communes) { [need.facility.commune] }

      it 'creates the matches' do
        expect(diagnosis.matches).not_to be_empty
        expect(diagnosis.step).to eq('matches')
      end
    end

    context 'there are no relevant experts' do
      let(:the_subject) { create :subject }
      let(:communes) { [need.facility.commune] }

      it 'sets an error' do
        expect(diagnosis.errors.details).to eq({ matches: [{ error: :preselected_institution_has_no_relevant_experts }] })
        expect(diagnosis.step).to eq('matches')
      end
    end

    context 'solicitation has other_need_subject' do
      let(:solicitation) { create :solicitation, landing_subject: create(:landing_subject, subject: other_need_subject) }
      let(:the_subject) { other_need_subject }
      let(:communes) { [need.facility.commune] }

      it 'returns silently' do
        expect(diagnosis.matches).to be_empty
        expect(diagnosis.errors).to be_empty
        expect(diagnosis.step).to eq('needs')
      end
    end
  end
end
