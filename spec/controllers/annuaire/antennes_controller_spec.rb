require 'rails_helper'

RSpec.describe Annuaire::AntennesController do
  login_admin

  describe 'GET #index' do
    let(:institution_1) { create :institution }
    let!(:antenne_1) { create :antenne, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: '29001')], institution: institution_1 }
    let!(:antenne_2) { create :antenne, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: '67001')], institution: institution_1 }

    subject(:request) { get :index, params: { institution_slug: institution_1.slug } }

    it 'return all institution antennes' do
      request
      expect(assigns(:antennes)).to match_array(institution_1.antennes)
    end
  end
end
