require 'rails_helper'

RSpec.describe TerritorialZone do
  describe 'associations' do
    it { is_expected.to belong_to(:zoneable) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:zone_type) }
  end

  describe 'custom validations' do
    describe '#validate_code_format' do
      context 'when zone_type is commune' do
        let(:valid_commune) { build(:territorial_zone, :commune) }
        let(:invalid_commune) { build(:territorial_zone, :commune, code: '123') }

        it 'is invalid if code does not match INSEE format' do
          expect(valid_commune).to be_valid
          expect(invalid_commune).not_to be_valid
          expect(invalid_commune.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.format_invalid', zone_type: :commune))
        end
      end

      context 'when zone_type is departement' do
        let(:valid_departement) { build(:territorial_zone, :departement) }
        let(:invalid_departement) { build(:territorial_zone, :departement, code: '1') }

        it 'is invalid if code does not match department format' do
          expect(valid_departement).to be_valid
          expect(invalid_departement).not_to be_valid
          expect(invalid_departement.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.format_invalid', zone_type: :departement))
        end
      end

      context 'when zone_type is region' do
        let(:valid_region) { build(:territorial_zone, :region) }
        let(:invalid_region) { build(:territorial_zone, :region, code: '1') }

        it 'is invalid if code does not match region format' do
          expect(valid_region).to be_valid
          expect(invalid_region).not_to be_valid
          expect(invalid_region.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.format_invalid', zone_type: :region))
        end
      end

      context 'when zone_type is epci' do
        let(:valid_epci) { build(:territorial_zone, :epci) }
        let(:invalid_epci) { build(:territorial_zone, :epci, code: '123') }

        it 'is invalid if code does not match EPCI format' do
          expect(valid_epci).to be_valid
          expect(invalid_epci).not_to be_valid
          expect(invalid_epci.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.format_invalid', zone_type: :epci))
        end
      end
    end
  end
end
