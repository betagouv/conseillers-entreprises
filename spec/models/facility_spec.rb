require 'rails_helper'

RSpec.describe Facility do
  describe 'associations' do
    it do
      is_expected.to belong_to :company
    end
  end

  describe 'validations' do
    subject { create(:facility) }

    it do
      is_expected.to validate_uniqueness_of(:siret).ignoring_case_sensitivity
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

  describe "scopes" do
    describe "by_region" do
      let(:region_code) { "52" }
      let!(:facility_in_region_1) { create :facility, insee_code: "44109" }
      let!(:facility_in_region_2) { create :facility, insee_code: "49007" }
      let!(:facility_not_in_region) { create :facility, insee_code: "70550" }

      subject { described_class.by_region(region_code) }

      it 'returns facilities in the region' do
        is_expected.to contain_exactly(facility_in_region_1, facility_in_region_2)
      end
    end
  end
end
