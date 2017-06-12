# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/show.html.haml', type: :view do
  let(:company_json) do
    JSON.parse(File.read(Rails.root.join('spec/responses/api_entreprise.json')))
  end

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

  it 'displays a title' do
    assign :company, ApiEntreprise::Company.new(company_json)
    assign :qwant_results, qwant_json
    render
    expect(rendered).to match(/Entreprises/)
  end
end
