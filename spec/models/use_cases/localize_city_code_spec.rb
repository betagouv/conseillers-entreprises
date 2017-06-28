# frozen_string_literal: true

require 'rails_helper'

describe UseCases::LocalizeCityCode do
  describe 'in_maubeuge?' do
    let(:in_maubeuge) { UseCases::LocalizeCityCode.new(city_code).in_maubeuge? }

    context 'is not in maubeuge perimeter' do
      let(:city_code) { 75108 }

      it 'should return false' do
        expect(in_maubeuge).to be_falsey
      end
    end

    context 'is in maubeuge perimeter' do
      let(:city_code) { 59169 }

      it 'should return true' do
        expect(in_maubeuge).to be_truthy
      end
    end
  end

  describe 'in_valencienne_cambrai?' do
    let(:in_valencienne_cambrai) { UseCases::LocalizeCityCode.new(city_code).in_valencienne_cambrai? }

    context 'is not in in_valencienne_cambrai perimeter' do
      let(:city_code) { 75108 }

      it 'should return false' do
        expect(in_valencienne_cambrai).to be_falsey
      end
    end

    context 'is in in_valencienne_cambrai perimeter' do
      let(:city_code) { 59603 }

      it 'should return true' do
        expect(in_valencienne_cambrai).to be_truthy
      end
    end
  end

  describe 'in_lens?' do
    let(:in_lens) { UseCases::LocalizeCityCode.new(city_code).in_lens? }

    context 'is not in in_lens perimeter' do
      let(:city_code) { 75108 }

      it 'should return false' do
        expect(in_lens).to be_falsey
      end
    end

    context 'is in in_lens perimeter' do
      let(:city_code) { 62573 }

      it 'should return true' do
        expect(in_lens).to be_truthy
      end
    end
  end

  describe 'in_calais?' do
    let(:in_calais) { UseCases::LocalizeCityCode.new(city_code).in_calais? }

    context 'is not in in_lens perimeter' do
      let(:city_code) { 75108 }

      it 'should return false' do
        expect(in_calais).to be_falsey
      end
    end

    context 'is in in_lens perimeter' do
      let(:city_code) { 62769 }

      it 'should return true' do
        expect(in_calais).to be_truthy
      end
    end
  end
end
