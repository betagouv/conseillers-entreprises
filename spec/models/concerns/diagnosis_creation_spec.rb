# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosisCreation do
  describe 'new_diagnosis' do
    context 'with a solicitation' do
      subject(:diagnosis){ described_class.new_diagnosis(solicitation) }

      let(:solicitation) { build :solicitation, full_name: 'my company' }

      it do
        expect(diagnosis.facility.company.name).to eq 'my company'
      end
    end
  end

  describe 'create_diagnosis' do
    # the subject has to be called as a block (expect{create_diagnosis}) for raise matchers to work correctly.
    subject(:create_diagnosis) { described_class.create_diagnosis(params) }

    let(:advisor) { create :user }
    let(:params) { { advisor: advisor, facility_attributes: facility_params } }

    context 'with invalid facility data' do
      let(:facility_params) { { invalid: 'value' } }

      it do
        expect{ create_diagnosis }.to raise_error ActiveModel::UnknownAttributeError
      end
    end

    context 'with a facility siret' do
      let(:siret) { '12345678901234' }
      let(:facility_params) { { siret: siret } }

      context 'when the siret is valid' do
        before do
          allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { create(:facility, siret: siret) }
        end

        it 'fetches info for ApiEntreprise and creates the diagnosis' do
          expect{ create_diagnosis }.not_to raise_error
          expect(create_diagnosis).to be_valid
        end
      end

      context 'when the siret is unknown' do
        before do
          allow(UseCases::SearchFacility).to receive(:with_siret_and_save).with(siret) { raise ApiEntreprise::ApiEntrepriseError, 'some error message' }
        end

        it 'fetches info for ApiEntreprise and creates the diagnosis' do
          expect{ create_diagnosis }.to raise_error ApiEntreprise::ApiEntrepriseError
        end
      end
    end

    context 'with manual facility info' do
      let(:insee_code) { '78586' }
      let(:facility_params) { { insee_code: insee_code, company_attributes: { name: 'Boucherie Sanzot' } } }

      before do
        city_json = JSON.parse(file_fixture('geo_api_communes_78586.json').read)
        allow(ApiAdresse::Query).to receive(:city_with_code).with(insee_code) { city_json }
      end

      it 'creates a new diagnosis without siret' do
        expect{ create_diagnosis }.not_to raise_error
        expect(create_diagnosis).to be_valid
        expect(create_diagnosis.company.name).to eq 'Boucherie Sanzot'
      end
    end
  end
end
