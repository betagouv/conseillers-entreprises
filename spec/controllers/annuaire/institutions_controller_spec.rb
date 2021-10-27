# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::InstitutionsController, type: :controller do
  login_admin

  describe 'GET #search' do
    subject(:request) { get :search, params: { region_id: region_ouest.id } }

    # Institution avec une antenne dans la région OK
    let(:institution_1) { create :institution }
    let!(:antenne_1) { create :antenne, institution: institution_1, communes: [commune_ouest] }
    # Institution avec une antenne en dehors de la région KO
    let(:institution_2) { create :institution }
    let!(:antenne_2) { create :antenne, institution: institution_2, communes: [commune_est] }
    # Institution avec une antenne dans la région et une antenne en dehors OK
    let(:institution_3) { create :institution }
    let!(:antenne_3_1) { create :antenne, institution: institution_3, communes: [commune_ouest] }
    let!(:antenne_3_2) { create :antenne, institution: institution_3, communes: [commune_est] }

    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    it 'return institutions with antennes in the selected region' do
      request
      expect(assigns(:institutions)).to match_array([institution_1, institution_3])
    end
  end
end
