# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'to_s' do
    it do
      company = create :company, name: 'Octo'
      expect(company.to_s).to eq 'Octo'
    end
  end
end
