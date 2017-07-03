# frozen_string_literal: true

require 'rails_helper'

describe UseCases::LocalizeCityCode do
  describe 'in_maubeuge?' do
    let(:in_maubeuge) { described_class.new(city_code).in_maubeuge? }

    context 'is not in maubeuge perimeter' do
      let(:city_code) { 75_108 }

      it 'returns false' do
        expect(in_maubeuge).to be_falsey
      end
    end

    context 'is in maubeuge perimeter' do
      let(:city_code) { 59_169 }

      it 'returns true' do
        expect(in_maubeuge).to be_truthy
      end
    end
  end

  describe 'in_valenciennes_cambrai?' do
    let(:in_valenciennes_cambrai) { described_class.new(city_code).in_valenciennes_cambrai? }

    context 'is not in in_valenciennes_cambrai perimeter' do
      let(:city_code) { 75_108 }

      it 'returns false' do
        expect(in_valenciennes_cambrai).to be_falsey
      end
    end

    context 'is in in_valenciennes_cambrai perimeter' do
      let(:city_code) { 59_603 }

      it 'returns true' do
        expect(in_valenciennes_cambrai).to be_truthy
      end
    end
  end

  describe 'in_lens?' do
    let(:in_lens) { described_class.new(city_code).in_lens? }

    context 'is not in in_lens perimeter' do
      let(:city_code) { 75_108 }

      it 'returns false' do
        expect(in_lens).to be_falsey
      end
    end

    context 'is in in_lens perimeter' do
      let(:city_code) { 62_573 }

      it 'returns true' do
        expect(in_lens).to be_truthy
      end
    end
  end

  describe 'in_calais?' do
    let(:in_calais) { described_class.new(city_code).in_calais? }

    context 'is not in in_lens perimeter' do
      let(:city_code) { 75_108 }

      it 'returns false' do
        expect(in_calais).to be_falsey
      end
    end

    context 'is in in_lens perimeter' do
      let(:city_code) { 62_769 }

      it 'returns true' do
        expect(in_calais).to be_truthy
      end
    end
  end
end
