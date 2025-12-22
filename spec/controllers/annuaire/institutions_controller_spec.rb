require 'rails_helper'

RSpec.describe Annuaire::InstitutionsController do
  login_admin

  describe 'GET #index' do
    let(:institution_1) { create :institution, :expert_provider }
    let!(:antenne_1) { create :antenne, institution: institution_1, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: '29001')] }
    let(:institution_2) { create :institution, :expert_provider }
    let!(:antenne_2) { create :antenne, institution: institution_2, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: '67001')] }
    let(:institution_3) { create :institution, :expert_provider }
    let!(:antenne_3_1) { create :antenne, institution: institution_3, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: '29001')] }
    let!(:antenne_3_2) { create :antenne, institution: institution_3, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: '67001')] }

    subject(:request) { get :index }

    it 'return all institutions' do
      request
      expect(assigns(:institutions)).to contain_exactly(institution_1, institution_2, institution_3)
    end
  end
end
