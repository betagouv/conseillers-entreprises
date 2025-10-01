require 'rails_helper'

RSpec.describe Annuaire::AntennesController do
  login_admin

  describe 'GET #index' do
    let(:institution_1) { create :institution }
    let!(:antenne_1) { create :antenne, communes: [commune_ouest], institution: institution_1 }
    let!(:antenne_2) { create :antenne, communes: [commune_est], institution: institution_1 }

    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    subject(:request) { get :index, params: { institution_slug: institution_1.slug } }

    it 'return all institution antennes' do
      request
      expect(assigns(:antennes)).to match_array(institution_1.antennes)
    end
  end
end
