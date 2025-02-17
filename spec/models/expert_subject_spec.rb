require 'rails_helper'

RSpec.describe ExpertSubject do
  describe 'validations' do
    it do
      is_expected.to belong_to :expert
      is_expected.to belong_to :institution_subject
    end
  end

  describe 'scopes' do
    describe 'relevant_for' do
      subject{ described_class.relevant_for(need) }

      let(:need) { create :need, facility: create(:facility, insee_code: "47203") }
      let!(:expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, subject: the_subject),
               expert: create(:expert, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: insee_code)])
      end

      context 'when the expert isn’t on the commune' do
        let(:the_subject) { need.subject }
        let(:communes) { [create(:commune)] }
        let(:insee_code) { "72026" }

        it{ is_expected.to be_blank }
      end

      context 'when the institution doesn’t handle that subject' do
        let(:the_subject) { create :subject }
        let(:insee_code) { "47203" }

        it{ is_expected.to be_blank }
      end

      context 'when both subject and institution match' do
        let(:the_subject) { need.subject }
        let(:insee_code) { "47203" }

        it{ is_expected.to contain_exactly(expert_subject) }
      end
    end

    describe "in_commune" do
      let(:insee_code) { "47203" }

      subject { described_class.in_commune(insee_code) }

      context "Commune direct" do
        let(:expert_with_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :commune, code: insee_code)] }
        let(:expert_without_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :commune, code: "72026")] }

        it "returns expert with the commune" do
          is_expected.to contain_exactly(expert_with_code.experts_subjects.first)
          is_expected.not_to include(expert_without_code.experts_subjects.first)
        end
      end
    end

    describe 'of_institution' do
      subject{ described_class.of_institution(institution) }

      let(:institution) { create :institution }
      let(:other_institution) { create :institution }
      let!(:expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: institution)
      end
      let!(:other_expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: other_institution)
      end

      it{ is_expected.to contain_exactly(expert_subject) }
    end

    describe 'not_of_institution' do
      subject{ described_class.not_of_institution(institution) }

      let(:institution) { create :institution }
      let(:other_institution) { create :institution }
      let!(:expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: institution)
      end
      let!(:other_expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: other_institution)
      end

      it{ is_expected.to contain_exactly(other_expert_subject) }
    end

    describe 'without_irrelevant_opcos' do
      subject{ described_class.without_irrelevant_opcos(facility) }

      let(:opco) { create :institution, :opco }
      let(:other_opco) { create :institution, :opco }
      let!(:expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: opco)
      end
      let!(:other_expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: other_opco)
      end

      context 'when facility opco exists' do
        let(:facility) { create :facility, opco: opco }

        it { is_expected.to contain_exactly(expert_subject) }
      end

      context 'when facility has no opco' do
        let(:facility) { create :facility, opco: nil }

        it{ is_expected.to be_blank }
      end

      context 'when facility from Mayotte' do
        let(:region_mayotte) { create :territory, name: "Département Mayotte", code_region: 6 }
        let!(:facility) { create :facility, opco: opco, commune: commune_mayotte }
        let(:commune_mayotte) { create :commune, regions: [region_mayotte] }
        let(:mayotte_opco) { create :institution, :opco, slug: 'opco-akto-mayotte' }
        let!(:expert_subject_mayotte) do
          create :expert_subject,
                 institution_subject: create(:institution_subject, institution: mayotte_opco)
        end

        it { is_expected.to contain_exactly(expert_subject_mayotte) }
      end
    end

    describe 'without_irrelevant_chambres' do
      subject{ described_class.without_irrelevant_chambres(facility) }

      let(:need) { create :need, facility: facility }
      let!(:expert_subject_cci) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: create(:institution, name: 'cci'))
      end
      let!(:expert_subject_cma) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: create(:institution, name: 'cma'))
      end
      let!(:expert_subject_unapl) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: create(:institution, name: 'unapl'))
      end

      let!(:expert_subject_temoin) do
        create :expert_subject,
               institution_subject: create(:institution_subject, institution: create(:institution, name: 'other'))
      end
      let(:company) { create :company, forme_exercice: forme_exercice }
      let(:facility) { create :facility, company: company, nature_activites: nature_activites }

      context 'when facility has no nature activites' do
        let(:forme_exercice) { nil }
        let(:nature_activites) { [] }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_cci, expert_subject_cma, expert_subject_unapl) }
      end

      context 'when only facility has cci nature activites' do
        let(:forme_exercice) { nil }
        let(:nature_activites) { ['COMMERCIALE'] }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_cci) }
      end

      context 'when only company has cma nature activites' do
        let(:forme_exercice) { 'ARTISANALE' }
        let(:nature_activites) { [] }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_cma) }
      end

      context 'when only liberale nature activites' do
        let(:forme_exercice) { 'LIBERALE_REGLEMENTEE' }
        let(:nature_activites) { [] }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_unapl) }
      end

      context 'when cci + cma nature activites' do
        let(:forme_exercice) { 'ARTISANALE_REGLEMENTEE' }
        let(:nature_activites) { ['AGENT_COMMERCIAL'] }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_cma, expert_subject_cci) }
      end

      context 'when liberale + cma nature activites' do
        let(:forme_exercice) { 'ARTISANALE_REGLEMENTEE' }
        let(:nature_activites) { ['LIBERALE_NON_REGLEMENTEE'] }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_cma, expert_subject_unapl) }
      end

      context 'when commercial nature activites + nafa_codes' do
        let(:forme_exercice) { 'COMMERCIALE' }
        let(:nature_activites) { [] }

        before { facility.update(nafa_codes: ['4002CZ']) }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_cma, expert_subject_cci) }
      end

      context 'when independant nature activites' do
        let(:forme_exercice) { 'INDEPENDANTE' }
        let(:nature_activites) { [] }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_cci, expert_subject_cma, expert_subject_unapl) }
      end

      context 'when GESTION_DE_BIENS nature activites' do
        let(:forme_exercice) { 'GESTION_DE_BIENS' }
        let(:nature_activites) { [] }

        it{ is_expected.to contain_exactly(expert_subject_temoin, expert_subject_cci, expert_subject_cma, expert_subject_unapl) }
      end

      context 'when agricole nature activites' do
        let(:forme_exercice) { 'ACTIF_AGRICOLE' }
        let(:nature_activites) { ['AGRICOLE_NON_ACTIF'] }

        it{ is_expected.to contain_exactly(expert_subject_temoin) }
      end

      context 'when other nature activites' do
        let(:forme_exercice) { 'SANS_ACTIVITE' }
        let(:nature_activites) { [] }

        it{ is_expected.to contain_exactly(expert_subject_temoin) }
      end
    end
  end

  describe 'csv_description' do
    subject { expert_subject.csv_description }

    let(:expert_subject) { build :expert_subject, intervention_criteria: intervention_criteria }

    context 'with criteria' do
      let(:intervention_criteria) { 'Intervention criteria' }

      it { is_expected.to eq 'Intervention criteria' }
    end

    context 'empty criteria' do
      let(:intervention_criteria) { '' }

      it { is_expected.to eq 'x' }
    end
  end

  describe 'csv_description=' do
    before { expert_subject.csv_description = csv }

    let(:expert_subject) { build :expert_subject, intervention_criteria: nil }

    context 'with criteria' do
      let(:csv) { 'Intervention criteria' }

      it do
        expect(expert_subject.intervention_criteria).to eq 'Intervention criteria'
      end
    end

    context 'empty criteria' do
      let(:csv) { 'X' }

      it do
        expect(expert_subject.intervention_criteria).to eq ''
      end
    end
  end
end
