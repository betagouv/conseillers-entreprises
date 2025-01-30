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
        let(:valid_commune) { build(:territorial_zone, :commune, code: '67549') }
        let(:invalid_commune) { build(:territorial_zone, :commune, code: '123') }

        it 'is invalid if code does not match INSEE format' do
          expect(valid_commune).to be_valid
          expect(invalid_commune).not_to be_valid
          expect(invalid_commune.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.invalid_format', zone_type: :commune))
        end
      end

      context 'when zone_type is departement' do
        let(:valid_departement) { build(:territorial_zone, :departement, code: '94') }
        let(:invalid_departement) { build(:territorial_zone, :departement, code: '1') }

        it 'is invalid if code does not match department format' do
          expect(valid_departement).to be_valid
          expect(invalid_departement).not_to be_valid
          expect(invalid_departement.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.invalid_format', zone_type: :departement))
        end
      end

      context 'when zone_type is region' do
        let(:valid_region) { build(:territorial_zone, :region, code: '53') }
        let(:invalid_region) { build(:territorial_zone, :region, code: '1') }

        it 'is invalid if code does not match region format' do
          expect(valid_region).to be_valid
          expect(invalid_region).not_to be_valid
          expect(invalid_region.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.invalid_format', zone_type: :region))
        end
      end

      context 'when zone_type is epci' do
        let(:valid_epci) { build(:territorial_zone, :epci, code: '249740119') }
        let(:invalid_epci) { build(:territorial_zone, :epci, code: '123') }

        it 'is invalid if code does not match EPCI format' do
          expect(valid_epci).to be_valid
          expect(invalid_epci).not_to be_valid
          expect(invalid_epci.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.invalid_format', zone_type: :epci))
        end
      end
    end

    describe '#validate_existence' do

      before do
        allow(DecoupageAdministratif::Commune).to receive(:find_by_code).with(code).and_return(response)
      end

      context 'Commune' do
        describe 'when code is valid' do
          let(:code) { '64474' }
          let(:response) { instance_double('DecoupageAdministratif::Commune', nom: 'Saint-Dos', code: code) }
          let(:valid_commune) { build(:territorial_zone, :commune, code: code) }

          it('is valid') { expect(valid_commune).to be_valid }
        end

        describe 'when code is invalid' do
          let(:code) { '99999' }
          let(:response) { nil }
          let(:invalid_commune) { build(:territorial_zone, :commune, code: code) }

          it 'is invalid' do
            expect(invalid_commune).not_to be_valid
            expect(invalid_commune.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.not_found', zone_type: :commune))
          end
        end
      end

      context 'Departement' do
        describe 'when code is valid' do
          let(:code) { '72' }
          let(:response) { instance_double(DecoupageAdministratif::Departement, nom: 'Sarthe', code: code) }
          let(:valid_departement) { build(:territorial_zone, :departement, code: code) }

          it('is valid') { expect(valid_departement).to be_valid }
        end

        describe 'when code is invalid' do
          let(:code) { '98' }
          let(:response) { nil }
          let(:invalid_departement) { build(:territorial_zone, :departement, code: code) }

          it 'is invalid' do
            expect(invalid_departement).not_to be_valid
            expect(invalid_departement.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.not_found', zone_type: :departement))
          end
        end
      end

      context 'Region' do
        describe 'when code is valid' do
          let(:code) { '53' }
          let(:response) { instance_double(DecoupageAdministratif::Region, nom: 'Bretagne', code: code) }
          let(:valid_region) { build(:territorial_zone, :region, code: code) }

          it('is valid') { expect(valid_region).to be_valid }
        end

        describe 'when code is invalid' do
          let(:code) { '98' }
          let(:response) { nil }
          let(:invalid_region) { build(:territorial_zone, :region, code: code) }

          it 'is invalid' do
            expect(invalid_region).not_to be_valid
            expect(invalid_region.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.not_found', zone_type: :region))
          end
        end
      end

      context 'Epci' do
        describe 'when code is valid' do
          let(:code) { '200054781' }
          let(:response) { instance_double(DecoupageAdministratif::Epci, nom: 'Métropole du Grand Paris', code: code) }
          let(:valid_epci) { build(:territorial_zone, :epci, code: code) }

          it('is valid') { expect(valid_epci).to be_valid }
        end

        describe 'when code is invalid' do
          let(:code) { '98' }
          let(:response) { nil }
          let(:invalid_epci) { build(:territorial_zone, :epci, code: code) }

          it 'is invalid' do
            expect(invalid_epci).not_to be_valid
            expect(invalid_epci.errors[:code]).to include(I18n.t('activerecord.errors.models.territorial_zones.code.not_found', zone_type: :epci))
          end
        end
      end

    end
  end
end
