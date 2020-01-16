require 'rails_helper'

RSpec.describe MatchesController, type: :controller do
  login_user

  describe 'PUT #update' do
    subject(:request) { put :update, xhr: true, params: params }

    let(:params) { { id: match.id, status: :taking_care } }
    let(:match) { create :match }

    context 'match does not exist' do
      let(:params) { { id: 'nonexisting' } }

      it('raises error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'match is available to expert' do
      before { current_user.update experts: [match.expert] }

      it 'returns http success' do
        request

        expect(response).to be_successful
        expect(match.reload.status_taking_care?).to eq true
      end
    end
  end
end
