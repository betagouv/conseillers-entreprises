# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :advisor
      is_expected.to belong_to :visitee
      is_expected.to belong_to :facility
      is_expected.to have_one :diagnosis
      is_expected.to validate_presence_of :advisor
      is_expected.to validate_presence_of :facility
    end
  end

  describe 'scopes' do
    describe 'of_siret' do
      subject { Visit.of_siret facility.siret }

      let(:facility) { create :facility, siret: '44622002200229' }

      context 'visit exists' do
        it do
          visit = create :visit, facility: facility
          is_expected.to eq [visit]
        end
      end

      context 'visit does not exist' do
        it do
          create :visit
          is_expected.to be_empty
        end
      end
    end
  end

  describe 'happened_on_localized' do
    it do
      visit = create :visit, happened_on: Date.new(2017, 7, 1)
      expect(visit.happened_on_localized).to eq '01/07/2017'
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

  describe 'can_be_viewed_by?' do
    subject { visit.can_be_viewed_by?(user) }

    let(:visit) { create :visit, advisor: advisor }
    let(:user) { create :user }

    context 'visit advisor is the user' do
      let(:advisor) { user }

      it { is_expected.to eq true }
    end

    context 'visit advisor is not the user' do
      let(:advisor) { create :user }

      it { is_expected.to eq false }
    end
  end
end
