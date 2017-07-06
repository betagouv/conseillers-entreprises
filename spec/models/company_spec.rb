# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to have_many :contacts }
  end

  describe 'to_s' do
    it do
      company = create :company, name: 'Octo'
      expect(company.to_s).to eq 'Octo'
    end
  end

  describe 'name_short' do
    it do
      name = 'This name is very long and should be shorter if we want to display it'
      company = create :company, name: name
      expect(company.name_short.length).to be < name.length
    end
  end
end
