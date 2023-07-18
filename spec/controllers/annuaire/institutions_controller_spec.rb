# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annuaire::InstitutionsController do
  login_admin

  describe 'GET #index' do
    let(:institution_1) { create :institution, :expert_provider }
    let!(:antenne_1) { create :antenne, institution: institution_1, communes: [commune_ouest] }
    let(:institution_2) { create :institution, :expert_provider }
    let!(:antenne_2) { create :antenne, institution: institution_2, communes: [commune_est] }
    let(:institution_3) { create :institution, :expert_provider }
    let!(:antenne_3_1) { create :antenne, institution: institution_3, communes: [commune_ouest] }
    let!(:antenne_3_2) { create :antenne, institution: institution_3, communes: [commune_est] }
    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    subject(:request) { get :index }

    it 'return all institutions' do
      request
      expect(assigns(:institutions)).to match_array([institution_1, institution_2, institution_3])
    end
  end
end
