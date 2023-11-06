require 'rails_helper'

RSpec.describe MatchesController do
  describe 'PUT #update' do
    login_user
    subject(:request) { put :update, xhr: true, params: params }

    let(:params) { { id: match.id, status: :taking_care } }
    let(:match) { create :match }

    context 'match does not exist' do
      let(:params) { { id: 'nonexisting' } }

      it('raises error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'match is available to expert' do
      login_user
      before { current_user.update experts: [match.expert] }

      it 'returns http success and send email' do
        request

        expect(response).to be_successful
        expect(match.reload.status_taking_care?).to be true
        expect(Sidekiq::Worker.jobs.count).to eq 1
        expect(Sidekiq::Worker.jobs.last['queue']).to eq 'match_notify'
      end
    end

    context 'current_user is an admin and include in match.experts' do
      login_admin
      before { current_user.update experts: [match.expert] }

      it 'returns http success and send email' do
        request

        expect(response).to be_successful
        expect(match.reload.status_taking_care?).to be true
        expect(Sidekiq::Worker.jobs.count).to eq 1
        expect(Sidekiq::Worker.jobs.last['queue']).to eq 'match_notify'
      end
    end

    context 'current_user is an admin and not include in match.experts' do
      login_admin

      it 'returns http success and don’t send email' do
        request

        expect(response).to be_successful
        expect(match.reload.status_taking_care?).to be true
        expect(Sidekiq::Worker.jobs.count).to eq 0
      end
    end
  end
end
