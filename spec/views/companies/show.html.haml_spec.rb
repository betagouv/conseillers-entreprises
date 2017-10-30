# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/show.html.haml', type: :view do
  let(:company_json) do
    JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'api_entreprise_get_entreprise.json')))
  end

  let(:facility_json) do
    JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'api_entreprise_get_etablissement.json')))
  end

  let(:diagnoses) { create_list :diagnosis, 2 }

  let(:qwant_json) do
    {
      'data' => {
        'result' => {
          'items' => [
            {
              'title' => 'Rejoins <b>OCTO</b>',
              'favicon' => '//s.qwant.com/fav/o/c/rejoins_octo_com.ico',
              'url' => 'http =>//rejoins.octo.com/',
              'source' => 'rejoins.<b>octo</b>.com',
              'desc' => 'Nos tribus - Devenir un <b>Octo</b> - Nos offres d\'emploi - Nos offres de stage.',
              '_id' => '1234567890',
              'position' => 8
            }
          ]
        }
      }
    }
  end

  before do
    assign :facility, ApiEntreprise::EtablissementWrapper.new(facility_json)
    assign :company, ApiEntreprise::EntrepriseWrapper.new(company_json)
    assign :diagnoses, diagnoses
    assign :qwant_results, qwant_json
    render
  end

  it('displays a title') { expect(rendered).to match(/Informations sur/) }
end
