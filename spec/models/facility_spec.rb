# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Facility, type: :model do
  describe 'validations' do
    subject { build(:facility) }

    it do
      is_expected.to belong_to :company
      is_expected.to validate_presence_of :company
      is_expected.to validate_uniqueness_of(:siret).ignoring_case_sensitivity
    end
  end

  describe 'scopes' do
    describe 'in_territory' do
      subject { Facility.in_territory territory }

      let(:territory) { create :territory }
      let(:facility) { create :facility, commune: commune }
      let(:commune) { create :commune, insee_code: '59001' }

      context 'with territory cities' do
        before { create :territory_city, territory: territory, commune: commune }

        it { is_expected.to eq [facility] }
      end

      context 'without territory city' do
        it { is_expected.to eq [] }
      end
    end
  end

  describe 'to_s' do
    subject { facility.to_s }

    let(:facility) { create :facility, readable_locality: '59600 Maubeuge', company: company }
    let(:company) { create :company, name: 'Mc Donalds' }

    it { is_expected.to eq 'Mc Donalds (59600 Maubeuge)' }
  end
end
