# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it do
      is_expected.to allow_value('test@beta.gouv.fr').for(:email)
      is_expected.not_to allow_value('test').for(:email)
    end
  end
end
