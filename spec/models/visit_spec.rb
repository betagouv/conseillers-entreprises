# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :advisor
      is_expected.to belong_to :visitee
      is_expected.to validate_presence_of :happened_at
      is_expected.to validate_presence_of :siret
      is_expected.to validate_presence_of :advisor
    end
  end
end
