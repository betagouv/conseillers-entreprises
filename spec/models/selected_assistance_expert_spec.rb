# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelectedAssistanceExpert, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :diagnosed_need
      is_expected.to belong_to :assistance_expert
      is_expected.to validate_presence_of :diagnosed_need
      is_expected.to validate_presence_of :assistance_expert
    end
  end
end
