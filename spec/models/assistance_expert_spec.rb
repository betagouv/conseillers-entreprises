# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssistanceExpert, type: :model do
  describe 'validations' do
    it do
      is_expected.to have_many(:matches).dependent(:nullify)
      is_expected.to belong_to :assistance
      is_expected.to belong_to :expert
    end
  end

  describe 'scopes' do
    describe 'of_city_code' do
      subject { AssistanceExpert.of_city_code city_code }

      let(:city_code) { '59003' }
      let(:maubeuge_expert) { create :expert }
      let(:maubeuge_experts) { [maubeuge_expert] }
      let(:maubeuge_territory) { create :territory, name: 'Maubeuge', experts: maubeuge_experts }
      let!(:maubeuge_assistance_expert) { create :assistance_expert, expert: maubeuge_expert }

      before do
        create :assistance_expert
        create :territory, name: 'Valenciennes', experts: [maubeuge_expert]
        create :territory_city, territory: maubeuge_territory, city_code: '59003'
        create :territory_city, territory: maubeuge_territory, city_code: '59006'
      end

      context 'one assistance_expert' do
        it { is_expected.to eq [maubeuge_assistance_expert] }
      end

      context 'several experts in maubeuge' do
        let(:other_maubeuge_expert) { create :expert }
        let(:maubeuge_experts) { [maubeuge_expert, other_maubeuge_expert] }

        it { is_expected.to eq [maubeuge_assistance_expert] }
      end

      context 'several assistance_expertss on this location and territory' do
        let!(:other_assistance_expert) { create :assistance_expert, expert: maubeuge_expert }

        it { is_expected.to match_array [maubeuge_assistance_expert, other_assistance_expert] }
      end

      context 'several assistances_experts on this location but another territory' do
        let(:other_territory_expert) { create :expert }
        let(:other_territory) { create :territory, name: 'Maubeuge', experts: [other_territory_expert] }
        let!(:other_territory_assistance_expert) { create :assistance_expert, expert: other_territory_expert }

        before { create :territory_city, territory: other_territory, city_code: city_code }

        it { is_expected.to match_array [maubeuge_assistance_expert, other_territory_assistance_expert] }
      end

      context 'city code in neither' do
        let(:city_code) { '75108' }

        it { is_expected.to be_empty }
      end
    end

    describe 'of_naf_code' do
      subject { AssistanceExpert.of_naf_code naf_code }

      let(:commerce_naf_code) { '6202A' }
      let(:artisanry_naf_code) { '1011Z' }

      let(:commerce_institution) { create :institution, qualified_for_artisanry: false, qualified_for_commerce: true }
      let(:artisanry_institution) { create :institution, qualified_for_artisanry: true, qualified_for_commerce: false }

      let(:artisanry_expert) { create :expert, institution: artisanry_institution }
      let(:commerce_expert) { create :expert, institution: commerce_institution }

      let!(:assistance_expert_for_artisanry) { create :assistance_expert, expert: artisanry_expert }
      let!(:assistance_expert_for_commerce) { create :assistance_expert, expert: commerce_expert }

      context 'naf code is for artisanry' do
        let(:naf_code) { artisanry_naf_code }

        it 'returns the assistance expert for artisanry' do
          is_expected.to match_array [assistance_expert_for_artisanry]
        end
      end

      context 'naf code is for commerce' do
        let(:naf_code) { commerce_naf_code }

        it 'returns the assistance expert for commerce' do
          is_expected.to match_array [assistance_expert_for_commerce]
        end
      end
    end
  end
end
