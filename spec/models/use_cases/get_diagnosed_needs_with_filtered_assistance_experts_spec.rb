# frozen_string_literal: true

require 'rails_helper'

describe UseCases::GetDiagnosedNeedsWithFilteredAssistanceExperts do
  describe 'of_diagnosis' do
    subject(:diagnosed_needs) { described_class.of_diagnosis(diagnosis) }

    let(:commune) { create :commune, insee_code: '75001' }
    let(:facility) { create :facility, commune: commune, naf_code: artisanry_naf_code }
    let(:visit) { create :visit, facility: facility }
    let!(:territory) { create :territory }

    let!(:diagnosis) { create :diagnosis, visit: visit }
    let!(:question1) { create :question }
    let!(:question2) { create :question }
    let!(:assistance1) { create :assistance, question: question1 }
    let!(:assistance2) { create :assistance, question: question2 }

    let(:artisanry_naf_code) { '1011Z' }

    let(:expert_territory1) { create :expert_territory, territory: territory }
    let(:artisanry_institution) { create :institution, qualified_for_artisanry: true, qualified_for_commerce: false }
    let(:artisanry_expert) do
      create :expert, institution: artisanry_institution, expert_territories: [expert_territory1]
    end

    let(:expert_territory2) { create :expert_territory, territory: territory }
    let(:commerce_institution) { create :institution, qualified_for_artisanry: false, qualified_for_commerce: true }
    let(:commerce_expert) do
      create :expert, institution: commerce_institution, expert_territories: [expert_territory2]
    end

    let!(:diagnosed_need1) { create :diagnosed_need, diagnosis: diagnosis, question: question1 }
    let!(:diagnosed_need2) { create :diagnosed_need, diagnosis: diagnosis, question: question2 }

    before do
      create :diagnosed_need
      territory.communes << commune
    end

    context 'with assistance experts' do
      let!(:assistance_expert_for_artisanry) do
        create :assistance_expert, expert: artisanry_expert, assistance: assistance1
      end

      before do
        create :assistance_expert, assistance: assistance1
        create :assistance_expert, assistance: assistance2
        create :assistance_expert, expert: commerce_expert, assistance: assistance1
      end

      it 'gets the right diagnosed needs' do
        expect(diagnosed_needs).to match_array [diagnosed_need1, diagnosed_need2]
      end

      it 'includes the rightly filtered assistance experts' do
        returned_assistance_experts = diagnosed_needs.map(&:question)
          .flat_map(&:assistances)
          .flat_map(&:filtered_assistances_experts)
        expect(returned_assistance_experts).to contain_exactly(assistance_expert_for_artisanry)
      end

      it 'does not delete the other assistances_experts' do
        diagnosed_needs

        commerce_expert_assistance_experts = commerce_expert.reload.assistances_experts
        expect(commerce_expert_assistance_experts.count).to eq 1
      end
    end

    context 'no assistance experts' do
      it 'displays diagnosed needs anyway' do
        expect(diagnosed_needs).to match_array [diagnosed_need1, diagnosed_need2]
      end
    end
  end
end
