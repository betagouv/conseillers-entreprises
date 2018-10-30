# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssistanceExpert, type: :model do
  describe 'validations' do
    it do
      is_expected.to have_many(:matches).dependent(:nullify)
      is_expected.to belong_to :assistance
      is_expected.to belong_to :expert
    end
  end
end
