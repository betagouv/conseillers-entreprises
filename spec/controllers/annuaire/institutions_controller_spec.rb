# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::InstitutionsController, type: :controller do
  login_admin

  describe 'GET #index' do
    let(:institution_1) { create :institution }
    let!(:antenne_1) { create :antenne, institution: institution_1, communes: [commune_ouest] }
    let(:institution_2) { create :institution }
    let!(:antenne_2) { create :antenne, institution: institution_2, communes: [commune_est] }
    let(:institution_3) { create :institution }
    let!(:antenne_3_1) { create :antenne, institution: institution_3, communes: [commune_ouest] }
    let!(:antenne_3_2) { create :antenne, institution: institution_3, communes: [commune_est] }
    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    context 'without region params' do
      subject(:request) { get :index }

      it 'return all institutions' do
        request
        expect(assigns(:institutions)).to match_array(Institution.all)
      end
    end

    context 'with region params' do
      subject(:request) { get :index, params: { region_id: region_ouest.id } }
      # Institution avec une antenne dans la région OK (institution_1)
      # Institution avec une antenne en dehors de la région KO (institution_2)
      # Institution avec une antenne dans la région et une antenne en dehors OK (institution_3)

      it 'return institutions for the selected region' do
        request
        expect(assigns(:institutions)).to match_array([institution_1, institution_3])
      end
    end
  end
end
