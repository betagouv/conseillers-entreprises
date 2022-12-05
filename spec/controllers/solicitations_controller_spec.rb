require 'rails_helper'

RSpec.describe SolicitationsController do
  describe 'GET #redirect_to_solicitation_step' do
    subject(:request) { get :redirect_to_solicitation_step, params: { uuid: solicitation.uuid, relaunch: 'relance-sollicitation' } }

    let!(:solicitation) { create :solicitation, full_name: "JJ Goldman", email: 'test@example.com', phone_number: 'xx', completed_at: nil, status: status, siret: siret }

    context 'step_company solicitation' do
      let(:status) { :step_company }
      let(:siret) { nil }

      it 'returns http success' do
        expect(response).to be_successful
      end
    end

    context 'step_description solicitation' do
      let!(:solicitation) { create :solicitation, full_name: "JJ Goldman", email: 'test@example.com', phone_number: 'xx', completed_at: nil, status: :step_description, siret: '41816609600069' }

      it 'returns http success' do
        expect(response).to be_successful
      end
    end
  end
end
