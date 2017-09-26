# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assistance, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :question
      is_expected.to belong_to :institution
      is_expected.to have_many(:assistances_experts).dependent(:destroy)
      is_expected.to have_many :experts
      is_expected.to validate_presence_of :title
      is_expected.to validate_presence_of :question
      is_expected.to validate_presence_of :institution
    end
  end

  describe 'county and geographic scope' do
    subject(:assistance) { build :assistance, geographic_scope: geographic_scope, county: county }

    context 'county geographic scope' do
      let(:geographic_scope) { :county }

      context 'without county' do
        let(:county) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'with wrong county' do
        let(:county) { 75 }

        it { is_expected.not_to be_valid }
      end

      context 'with authorized county' do
        let(:county) { Assistance::AUTHORIZED_COUNTIES.sample }

        it { is_expected.to be_valid }
      end
    end

    context 'region geographic scope' do
      let(:geographic_scope) { :region }
      let(:county) { nil }

      it { is_expected.to be_valid }
    end
  end

  describe 'scopes' do
    describe 'of_diagnosis' do
      subject { Assistance.of_diagnosis diagnosis }

      let(:diagnosis) { create :diagnosis }
      let(:question) { create :question }

      before { create :diagnosed_need, diagnosis: diagnosis, question: question }

      context 'one assistance' do
        let!(:assistance) { create :assistance, question: question }

        it { is_expected.to eq [assistance] }
      end

      context 'several assistances' do
        let!(:assistance) { create :assistance, question: question }
        let!(:assistance2) { create :assistance, question: question }

        it { is_expected.to match_array [assistance, assistance2] }
      end

      context 'no assistance' do
        it { is_expected.to be_empty }
      end
    end

    describe 'of_location' do
      subject { Assistance.of_location city_code }

      let(:city_code) { '59003' }
      let(:maubeuge_expert) { create :expert }
      let(:maubeuge_experts) { [maubeuge_expert] }
      let(:maubeuge_territory) { create :territory, name: 'Maubeuge', experts: maubeuge_experts }
      let!(:maubeuge_assistance) { create :assistance, experts: [maubeuge_expert] }

      before do
        create :assistance
        create :territory, name: 'Valenciennes', experts: [maubeuge_expert]
        create :territory_city, territory: maubeuge_territory, city_code: '59003'
        create :territory_city, territory: maubeuge_territory, city_code: '59006'
      end

      context 'one assistance' do
        it { is_expected.to eq [maubeuge_assistance] }
      end

      context 'several experts for an assistance' do
        let(:other_maubeuge_expert) { create :expert }
        let(:maubeuge_experts) { [maubeuge_expert, other_maubeuge_expert] }

        it { is_expected.to eq [maubeuge_assistance] }
      end

      context 'several assistances on this location and territory' do
        let!(:other_assistance) { create :assistance, experts: [maubeuge_expert] }

        it { is_expected.to match_array [maubeuge_assistance, other_assistance] }
      end

      context 'several assistances on this location but another territory' do
        let(:other_territory_expert) { create :expert }
        let(:other_territory) { create :territory, name: 'Maubeuge', experts: [other_territory_expert] }
        let!(:other_territory_assistance) { create :assistance, experts: [other_territory_expert] }

        before { create :territory_city, territory: other_territory, city_code: city_code }

        it { is_expected.to match_array [maubeuge_assistance, other_territory_assistance] }
      end

      context 'city code in neither' do
        let(:city_code) { '75108' }

        it { is_expected.to be_empty }
      end
    end
  end
end
