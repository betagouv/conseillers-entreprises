# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conseiller::CooperationsController do
  login_user

  let(:cooperation) { create :cooperation, root_url: 'https://exemple.fr' }
  let!(:user_right) { create :user_right, category: :cooperation_manager, user: current_user, rightable_element: cooperation }
  let(:solicitation) { create :solicitation, mtm_campaign: 'entreprendre', mtm_kwd: 'F1111', cooperation: cooperation }

  describe 'GET #needs' do
    it do
      get :needs
      expect(response).to be_successful
      expect(assigns(:cooperation)).to eq(cooperation)
    end
  end
end
