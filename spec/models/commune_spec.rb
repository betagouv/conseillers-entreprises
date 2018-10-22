require 'rails_helper'

RSpec.describe Commune, type: :model do
  describe 'city code uniqueness' do
    subject { build :commune, insee_code: insee_code }

    let(:insee_code) { '12345' }

    context 'unique code' do
      it { is_expected.to be_valid }
    end

    context 'reused code' do
      before { create :commune, insee_code: insee_code }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'insee code format' do
    it do
      is_expected.to allow_value('12345').for :insee_code
      is_expected.to allow_value('2A012').for :insee_code
      is_expected.not_to allow_value('6543').for :insee_code
      is_expected.not_to allow_value('1235 12345').for :insee_code
      is_expected.not_to allow_value('').for :insee_code
    end
  end
end
