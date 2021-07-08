# frozen_string_literal: true

require 'rails_helper'
describe CreateDiagnosis::CreateMatches do
  describe 'prepare_matches_from_solicitation' do
    let(:diagnosis) { create :diagnosis, solicitation: solicitation }
    let(:solicitation) { create :solicitation }
    let(:need) { create :need, diagnosis: diagnosis }

    let!(:expert_subject) do
      create :expert_subject,
             institution_subject: create(:institution_subject, institution: institution, subject: the_subject),
             expert: create(:expert, communes: communes)
    end

    let!(:expert_subject_cci) do
      create :expert_subject,
             institution_subject: create(:institution_subject, institution: cci, subject: the_subject),
             expert: create(:expert, communes: communes)
    end

    let!(:expert_subject_cma) do
      create :expert_subject,
             institution_subject: create(:institution_subject, institution: cma, subject: the_subject),
             expert: create(:expert, communes: communes)
    end

    let!(:institution) { create :institution }
    let!(:cci) { create :institution, name: 'cci' }
    let!(:cma) { create :institution, name: 'cma' }

    before do
      diagnosis.prepare_matches_from_solicitation
    end

    context 'there are relevant experts' do
      let(:the_subject) { need.subject }
      let(:communes) { [need.facility.commune] }

      it 'creates the matches' do
        expect(diagnosis.matches).not_to be_empty
      end
    end

    context 'there are no relevant experts' do
      let(:the_subject) { create :subject }
      let(:communes) { [need.facility.commune] }

      it 'sets an error' do
        expect(diagnosis.errors.details).to eq({ matches: [{ error: :preselected_institution_has_no_relevant_experts }] })
      end
    end
  end
end
