# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Facility, type: :model do
  describe 'validations' do
    subject { create(:facility) }

    it do
      is_expected.to belong_to :company
      is_expected.to validate_presence_of :company
      is_expected.to validate_uniqueness_of(:siret).ignoring_case_sensitivity
      is_expected.to validate_presence_of :commune
    end
  end

  describe 'to_s' do
    subject { facility.to_s }

    let(:facility) { create :facility, readable_locality: '59600 Maubeuge', company: company }
    let(:company) { create :company, name: 'Mc Donalds' }

    it { is_expected.to eq 'Mc Donalds (59600 Maubeuge)' }
  end

  describe '#insee_code=' do
    let(:facility) { build :facility }

    before do
      stub_request(:get, "https://geo.api.gouv.fr/communes/78586?fields=nom,codesPostaux")
        .to_return(body: file_fixture('geo_api_communes_78586.json'))
    end

    it do
      facility.insee_code = '78586'

      expect(facility.readable_locality).to eq '78500 Sartrouville'
    end
  end
end
