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

    describe 'insee_code format' do
      it 'accepts valid 5-digit numeric codes' do
        facility = build(:facility, insee_code: '75056')
        expect(facility).to be_valid
      end

      it 'accepts codes with A (Corse)' do
        facility = build(:facility, insee_code: '2A001')
        expect(facility).to be_valid
      end

      it 'accepts codes with B (Corse)' do
        facility = build(:facility, insee_code: '2B033')
        expect(facility).to be_valid
      end

      it 'rejects codes shorter than 5 characters' do
        facility = build(:facility, insee_code: '7505')
        expect(facility).not_to be_valid
        expect(facility.errors[:insee_code]).to be_present
      end

      it 'rejects codes longer than 5 characters' do
        facility = build(:facility, insee_code: '750561')
        expect(facility).not_to be_valid
        expect(facility.errors[:insee_code]).to be_present
      end

      it 'rejects codes with invalid letters' do
        facility = build(:facility, insee_code: '2C001')
        expect(facility).not_to be_valid
        expect(facility.errors[:insee_code]).to be_present
      end

      it 'rejects blank insee_code' do
        facility = build(:facility, insee_code: nil)
        expect(facility).not_to be_valid
        expect(facility.errors[:insee_code]).to be_present
      end
    end
  end

  describe 'to_s' do
    subject { facility.to_s }

    let(:facility) { create :facility, readable_locality: '59600 Maubeuge', company: company }
    let(:company) { create :company, name: 'Mc Donalds' }

    it { is_expected.to eq 'Mc Donalds (59600 Maubeuge)' }
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

  describe "#region" do
    subject { facility.region }

    context "with valid insee_code" do
      let(:facility) { build :facility, insee_code: "44109" }

      it "returns the region" do
        expect(subject).to be_a(DecoupageAdministratif::Region)
        expect(subject).not_to be_nil
      end
    end
  end

  describe "#get_relevant_opco" do
    let!(:opco_akto) { create :institution, :opco, slug: 'opco-akto-mayotte' }
    let!(:opco_default) { create :institution, :opco }

    subject { facility.get_relevant_opco }

    context "when facility is in Mayotte (region code 06)" do
      let(:facility) { build :facility, insee_code: "97601", opco: opco_default }

      it "returns OPCO Akto Mayotte" do
        expect(subject).to eq(opco_akto)
      end
    end

    context "when facility is not in Mayotte" do
      let(:facility) { build :facility, insee_code: "44109", opco: opco_default }

      it "returns the facility's opco" do
        expect(subject).to eq(opco_default)
      end
    end
  end
end
