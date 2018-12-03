# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assistance, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :question
      is_expected.to have_many(:assistances_experts).dependent(:destroy)
      is_expected.to have_many :experts
      is_expected.to validate_presence_of :title
      is_expected.to validate_presence_of :question
    end
  end

  describe 'default value' do
    let(:assistance) { create :assistance }

    it 'returns nil for filtered_assistances_experts' do
      expect(assistance.filtered_assistances_experts).to be_nil
    end
  end
end
