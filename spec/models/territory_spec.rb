# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territory, type: :model do
  describe 'validations' do
    it do
      is_expected.to have_many :territory_cities
      is_expected.to have_many :expert_territories
      is_expected.to have_many :experts
    end
  end

  describe 'to_s' do
    let(:territory) { create :territory, name: 'Calaisis' }

    it { expect(territory.to_s).to include 'Calaisis' }
  end

  describe 'city_codes' do
    subject { territory.city_codes }

    let(:territory) { create :territory }

    context 'with territory cities' do
      before { create :territory_city, territory: territory, city_code: 59_001 }

      it { is_expected.to eq %w[59001] }
    end

    context 'without territory city' do
      it { is_expected.to eq [] }
    end
  end
end
