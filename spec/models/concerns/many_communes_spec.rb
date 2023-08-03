require 'rails_helper'

RSpec.describe ManyCommunes do
  describe 'insee_codes' do
    describe 'getter' do
      subject { territory.insee_codes }

      let(:territory) { create :territory }

      context 'with territory communes' do
        let(:commune) { create :commune, insee_code: '59001' }

        before { territory.communes = [commune] }

        it { is_expected.to eq '59001' }
      end

      context 'without territory city' do
        it { is_expected.to eq '' }
      end
    end

    describe 'setter' do
      subject { territory.insee_codes }

      let(:territory) { create :territory }

      context 'with invalid data' do
        let(:raw_codes) { 'baddata morebaddata' }

        before { territory.insee_codes = raw_codes }

        it do
          expect(territory).not_to be_valid
          expect(territory.errors.details).to eq({ insee_codes: [{ error: :invalid_insee_codes }] })
        end
      end

      context 'with empty data' do
        let(:raw_codes) { '' }

        before { territory.insee_codes = raw_codes }

        it { is_expected.to eq '' }
      end

      context 'with proper values' do
        let(:raw_codes) { '12345, 12346' }

        before { territory.insee_codes = raw_codes }

        it { is_expected.to eq '12345 12346' }
      end

      context 'with previous values' do
        before do
          territory.communes = [create(:commune, insee_code: '10001'), create(:commune, insee_code: '10002')]
          territory.insee_codes = raw_codes
        end

        let(:raw_codes) { '10002, 10003' }

        it { is_expected.to eq '10002 10003' }
      end
    end
  end

  describe 'intervention_zone_summary' do
    subject { antenne.intervention_zone_summary }

    let(:antenne) { create :antenne, communes: communes1 + communes2 + communes3 }
    let(:communes1) { create_list(:commune, 4) }
    let(:communes2) { create_list(:commune, 4) }
    let(:communes3) { create_list(:commune, 4) }
    let!(:territory1) { create :territory, name: "A", bassin_emploi: true, communes: communes1 }
    let!(:territory2) { create :territory, name: "B", bassin_emploi: true, communes: communes2.take(2) }

    it do
      is_expected.to eq({
        territories: [
          {
            territory: territory1,
            included: 4,
          },
          {
            territory: territory2,
            included: 2,
          }
        ],
        other: 6
      })
    end
  end
end
