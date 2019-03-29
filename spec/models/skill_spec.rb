# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :subject
      is_expected.to have_many(:experts_skills).dependent(:destroy)
      is_expected.to have_many :experts
      is_expected.to validate_presence_of :title
      is_expected.to validate_presence_of :subject
    end
  end
end
