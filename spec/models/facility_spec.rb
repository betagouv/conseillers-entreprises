# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Facility, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :company
      is_expected.to validate_presence_of :company
      is_expected.to validate_presence_of :siret
      is_expected.to validate_presence_of :postal_code
    end
  end
end
