# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :advisor
      is_expected.to belong_to :visitee
      is_expected.to belong_to :visitee
      is_expected.to validate_presence_of :happened_at
      is_expected.to validate_presence_of :advisor
    end
  end

  describe 'to_s' do
    context 'visit is linked to a company' do
      it do
        company = create :company
        visit = create :visit, company: company
        expect(visit.to_s).to include company.name
      end
    end

    context 'visit is not linked to a company' do
      it do
        visit = create :visit
        expect(visit.to_s).to start_with 'Visite du '
      end
    end
  end
end
