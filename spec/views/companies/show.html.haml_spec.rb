require 'rails_helper'

RSpec.describe 'companies/show' do
  login_user

  context 'with no API errors' do
    let(:company_json) do
      JSON.parse(file_fixture('api_adapter_company.json').read)
    end

    let(:facility_json) do
      JSON.parse(file_fixture('api_adapter_facility.json').read)
    end

    let(:diagnoses) { create_list :diagnosis, 2 }

    before do
      assign :diagnosis, build(:diagnosis)
      assign :facility, ApiConsumption::Models::Facility::ApiEntreprise.new(facility_json['etablissement'])
      assign :company, ApiConsumption::Models::Company::ApiEntreprise.new(company_json['entreprise'])
      assign :diagnoses, diagnoses
      render
    end

    it('displays a title') { expect(rendered).to match(/Raison Sociale/) }
  end

  context 'with API minor errors' do
    let(:company_json) do
      JSON.parse(file_fixture('api_adapter_company_errors.json').read)
    end

    let(:facility_json) do
      JSON.parse(file_fixture('api_adapter_facility_errors.json').read)
    end

    let(:diagnoses) { create_list :diagnosis, 2 }

    before do
      assign :diagnosis, build(:diagnosis)
      assign :facility, ApiConsumption::Models::Facility::ApiEntreprise.new(facility_json['etablissement'])
      assign :company, ApiConsumption::Models::Company::ApiEntreprise.new(company_json['entreprise'])
      assign :diagnoses, diagnoses
      render
    end

    it { expect(render).to have_css('h1', text: 'OCTO-TECHNOLOGY') }
  end
end
