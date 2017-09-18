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

      let!(:maubeuge_expert) { create :expert, on_maubeuge: true }
      let!(:valenciennes_cambrai_expert) { create :expert, on_valenciennes_cambrai: true }
      let!(:calais_expert) { create :expert, on_calais: true }
      let!(:lens_expert) { create :expert, on_lens: true }

      let!(:maubeuge_assistance) { create :assistance, experts: [maubeuge_expert] }
      let!(:multi_city_assistance) { create :assistance, experts: [maubeuge_expert, calais_expert, lens_expert] }
      let!(:valenciennes_cambrai_assistance) { create :assistance, experts: [valenciennes_cambrai_expert] }
      let!(:calais_assistance) { create :assistance, experts: [calais_expert] }
      let!(:lens_assistance) { create :assistance, experts: [lens_expert] }

      context 'city code in maubeuge' do
        let(:city_code) { 59_003 }

        it { is_expected.to match_array [maubeuge_assistance, multi_city_assistance] }
      end

      context 'city code in valenciennes_cambrai' do
        let(:city_code) { 59_075 }

        it { is_expected.to match_array [valenciennes_cambrai_assistance] }
      end

      context 'city code in calais' do
        let(:city_code) { 62_055 }

        it { is_expected.to match_array [calais_assistance, multi_city_assistance] }
      end

      context 'city code in lens' do
        let(:city_code) { 62_065 }

        it { is_expected.to match_array [lens_assistance, multi_city_assistance] }
      end

      context 'city code in neither' do
        let(:city_code) { 75_108 }

        it { is_expected.to be_empty }
      end
    end
  end
end
