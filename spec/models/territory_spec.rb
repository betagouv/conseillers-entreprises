# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territory, type: :model do
  describe 'validations' do
    it do
      is_expected.to have_and_belong_to_many :communes
    end
  end

  describe 'to_s' do
    let(:territory) { create :territory, name: 'Calaisis' }

    it { expect(territory.to_s).to include 'Calaisis' }
  end

  describe 'insee_codes' do
    subject { territory.insee_codes }

    let(:territory) { create :territory }

    context 'with territory communes' do
      let(:commune) { create :commune, insee_code: '59001' }

      before { territory.communes = [commune] }

      it { is_expected.to eq %w[59001] }
    end

    context 'without territory city' do
      it { is_expected.to eq [] }
    end
  end

  describe 'insee_codes=' do
    subject { territory.insee_codes }

    let(:territory) { create :territory }

    context 'with invalid data' do
      subject(:set_insee_codes) { territory.insee_codes = raw_codes }

      let(:raw_codes) { 'baddata morebaddata' }

      it { expect { set_insee_codes }.to raise_error 'Invalid city codes' }
    end

    context 'with empty data' do
      let(:raw_codes) { '' }

      before { territory.insee_codes = raw_codes }

      it { is_expected.to eq [] }
    end

    context 'with proper values' do
      let(:raw_codes) { '12345, 12346' }

      before { territory.insee_codes = raw_codes }

      it { is_expected.to eq %w[12345 12346] }
    end

    context 'with previous values' do
      before {
        territory.communes = [create(:commune, insee_code: '10001'), create(:commune, insee_code: '10002')]
        territory.insee_codes = raw_codes
      }

      let(:raw_codes) { '10002, 10003' }

      it { is_expected.to eq %w[10002 10003] }
    end
  end
end
