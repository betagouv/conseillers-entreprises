# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/show.html.haml', type: :view do
  let(:company_json) do
    {
      'entreprise' => {
        'tranche_effectif_salarie_entreprise' => {},
        'mandataires_sociaux' => {}
      },
      'etablissement_siege' => {
        'tranche_effectif_salarie_etablissement' => {},
        'region_implantation' => {},
        'commune_implantation' => {},
        'pays_implantation' => {},
        'adresse' => {}
      }
    }
  end

  it 'displays a title' do
    assign :company, company_json
    render
    expect(rendered).to match(/Entreprises/)
  end
end
