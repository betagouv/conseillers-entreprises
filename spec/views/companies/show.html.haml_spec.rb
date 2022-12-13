# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/show' do
  login_user

  let(:company_json) do
    JSON.parse(file_fixture('api_company_adapter.json').read)
  end

  let(:facility_json) do
    JSON.parse(file_fixture('api_facility_adapter.json').read)
  end

  let(:diagnoses) { create_list :diagnosis, 2 }

  before do
    assign :diagnosis, build(:diagnosis)
    assign :facility, ApiConsumption::Models::Facility::ApiEntreprise.new(facility_json)
    assign :company, ApiConsumption::Models::Company::ApiEntreprise.new(company_json)
    assign :diagnoses, diagnoses
    render
  end

  it('displays a title') { expect(rendered).to match(/Raison Sociale/) }
end
