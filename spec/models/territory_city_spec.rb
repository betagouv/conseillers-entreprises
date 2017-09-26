# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerritoryCity, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :territory
      is_expected.to validate_presence_of :city_code
      is_expected.to validate_presence_of :territory
    end
  end

  describe 'city code format' do
    it do
      is_expected.to allow_value('65432').for :city_code
      is_expected.to allow_value('01234').for :city_code
      is_expected.not_to allow_value('6543').for :city_code
      is_expected.not_to allow_value('a1234').for :city_code
      is_expected.not_to allow_value('012345').for :city_code
    end
  end
end
