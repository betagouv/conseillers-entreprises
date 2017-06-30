# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expert, type: :model do
  describe 'validations' do
    it do
      is_expected.to validate_presence_of(:last_name)
      is_expected.to validate_presence_of(:role)
      is_expected.to validate_presence_of(:institution)
    end
  end

  describe 'full_name' do
    let(:expert) { build :expert, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(expert.full_name).to eq 'Ivan Collombet' }
  end

  describe 'scopes' do
    describe 'of_location' do
      subject { Expert.of_location city_code }

      let!(:maubeuge_expert) { create :expert, on_maubeuge: true }
      let!(:valenciennes_cambrai_expert) { create :expert, on_valenciennes_cambrai: true }
      let!(:calais_expert) { create :expert, on_calais: true }
      let!(:lens_expert) { create :expert, on_lens: true }

      context 'city code in maubeuge' do
        let(:city_code) { 59_003 }

        it { is_expected.to eq [maubeuge_expert] }
      end

      context 'city code in valenciennes_cambrai' do
        let(:city_code) { 59_075 }

        it { is_expected.to eq [valenciennes_cambrai_expert] }
      end

      context 'city code in calais' do
        let(:city_code) { 62_055 }

        it { is_expected.to eq [calais_expert] }
      end

      context 'city code in lens' do
        let(:city_code) { 62_065 }

        it { is_expected.to eq [lens_expert] }
      end

      context 'city code in neither' do
        let(:city_code) { 75_108 }

        it { is_expected.to eq [] }
      end
    end
  end
end
