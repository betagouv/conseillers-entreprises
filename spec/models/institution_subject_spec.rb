# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionSubject, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :subject
      is_expected.to belong_to :institution
    end
  end
end
