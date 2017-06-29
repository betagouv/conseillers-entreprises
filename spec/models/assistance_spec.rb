# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assistance, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :question
      is_expected.to belong_to :institution
      is_expected.to belong_to :expert
      is_expected.to validate_presence_of :title
      is_expected.to validate_presence_of :question
      is_expected.to validate_presence_of :institution
    end
  end

  describe 'validation of institution email' do
    subject(:assistance) { build :assistance, expert: expert, institution: institution }

    context 'without expert' do
      let(:expert) { nil }

      context 'with institution with email' do
        let(:institution) { create :institution, email: 'random@institution.com' }

        it { is_expected.to be_valid }
      end

      context 'with institution without email' do
        let(:institution) { create :institution, email: nil }

        it { is_expected.not_to be_valid }
      end
    end

    context 'with expert' do
      let(:expert) { create :expert }
      let(:institution) { create :institution, email: nil }

      it { is_expected.to be_valid }
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
    describe 'of_location' do
      subject { Assistance.of_location city_code }

      let!(:maubeuge_assistance) { create :assistance, for_maubeuge: true }
      let!(:valenciennes_cambrai_assistance) { create :assistance, for_valenciennes_cambrai: true }
      let!(:calais_assistance) { create :assistance, for_calais: true }
      let!(:lens_assistance) { create :assistance, for_lens: true }

      context 'city code in maubeuge' do
        let(:city_code) { 59_003 }

        it { is_expected.to eq [maubeuge_assistance] }
      end

      context 'city code in valenciennes_cambrai' do
        let(:city_code) { 59_075 }

        it { is_expected.to eq [valenciennes_cambrai_assistance] }
      end

      context 'city code in calais' do
        let(:city_code) { 62_055 }

        it { is_expected.to eq [calais_assistance] }
      end

      context 'city code in lens' do
        let(:city_code) { 62_065 }

        it { is_expected.to eq [lens_assistance] }
      end

      context 'city code in neither' do
        let(:city_code) { 75_108 }

        it { is_expected.to eq [] }
      end
    end
  end
end
