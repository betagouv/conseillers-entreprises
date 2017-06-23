# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :advisor
      is_expected.to belong_to :visitee
      is_expected.to belong_to :company
      is_expected.to belong_to :facility
      is_expected.to validate_presence_of :happened_at
      is_expected.to validate_presence_of :advisor
    end
  end

  describe 'to_s' do
    it do
      company = create :company
      visit = create :visit, company: company
      expect(visit.to_s).to include company.name
    end
  end

  describe 'happened_at_localized' do
    it do
      visit = create :visit, happened_at: Date.new(2017, 7, 1)
      expect(visit.happened_at_localized).to eq '01/07/2017'
    end
  end

  describe 'company_name' do
    it do
      name = 'Octo'
      company = create :company, name: name
      facility = create :facility, company: company
      visit = create :visit, facility: facility
      expect(visit.company_name).to eq name
    end
  end
end
