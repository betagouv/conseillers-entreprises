# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::AntennesController, type: :controller do
  login_admin

  describe 'GET #search' do
    subject(:request) { get :search, params: { institution_slug: institution_1.slug, region_id: region_ouest.id } }

    let(:institution_1) { create :institution }
    # Antenne dans la région OK
    let!(:antenne_1) { create :antenne, communes: [commune_ouest], institution: institution_1 }
    # Antenne en dehors de la région KO
    let!(:antenne_2) { create :antenne, communes: [commune_est], institution: institution_1 }

    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    it 'return antennes for the selected region' do
      request
      expect(assigns(:antennes)).to match_array([antenne_1])
    end
  end
end
