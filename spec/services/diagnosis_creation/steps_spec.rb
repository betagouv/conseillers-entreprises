require 'rails_helper'
require 'api'

describe DiagnosisCreation::Steps do
  describe 'prepare_needs_from_solicitation' do
    let(:diagnosis) { create :diagnosis, solicitation: solicitation }
    let(:solicitation) { create :solicitation }

    before do
      allow(solicitation).to receive(:preselected_subject).and_return(pde_subject)
      described_class.new(diagnosis).prepare_needs_from_solicitation
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
      described_class.new(diagnosis).prepare_visitee_from_solicitation
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
    let(:insee_code) { "23176" }
    let(:diagnosis) { build :diagnosis, solicitation: solicitation, step: 'needs', facility: create(:facility, insee_code: insee_code) }
    let(:solicitation) { create :solicitation }
    let(:need) { create :need, diagnosis: diagnosis }
    let!(:other_need_subject) { create :subject, id: 59 }

    let!(:expert_subject) do
      create :expert_subject,
             institution_subject: create(:institution_subject, institution: institution, subject: the_subject),
             expert: create(:expert, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: insee_code)])
    end
    let(:institution) { create :institution }

    before do
      described_class.new(diagnosis).prepare_matches_from_solicitation
    end

    context 'there are relevant experts' do
      let(:the_subject) { need.subject }

      it 'creates the matches' do
        expect(diagnosis.matches).not_to be_empty
        expect(diagnosis.step).to eq('matches')
      end
    end

    context 'there are no relevant experts' do
      let(:the_subject) { create :subject }

      it 'sets an error' do
        expect(diagnosis.errors.details).to eq({ matches: [{ error: :preselected_institution_has_no_relevant_experts }] })
        expect(diagnosis.step).to eq('matches')
      end
    end

    context 'solicitation has other_need_subject' do
      let(:solicitation) { create :solicitation, landing_subject: create(:landing_subject, subject: other_need_subject) }
      let(:the_subject) { other_need_subject }

      it 'returns silently' do
        expect(diagnosis.matches).to be_empty
        expect(diagnosis.errors).to be_empty
        expect(diagnosis.step).to eq('needs')
      end
    end
  end
end
