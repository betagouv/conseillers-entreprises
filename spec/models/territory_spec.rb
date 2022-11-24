# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territory do
  describe 'validations' do
    it do
      is_expected.to have_and_belong_to_many :communes
    end
  end
end
