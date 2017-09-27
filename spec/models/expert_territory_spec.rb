# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExpertTerritory, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :expert
      is_expected.to belong_to :territory
      is_expected.to validate_presence_of :expert
      is_expected.to validate_presence_of :territory
    end
  end
end
