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
end
