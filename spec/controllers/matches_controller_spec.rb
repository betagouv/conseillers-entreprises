require 'rails_helper'

RSpec.describe MatchesController do
  Sidekiq::Testing.disable!
  before { Sidekiq::ScheduledSet.new.clear }

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
        scheduled = Sidekiq::ScheduledSet.new
        request

        expect(response).to be_successful
        expect(match.reload.status_taking_care?).to be true
        expect(scheduled.size).to eq 1
        expect(scheduled.first.queue).to eq 'match_notify'
      end
    end

    context 'current_user is an admin and include in match.experts' do
      login_admin
      before { current_user.update experts: [match.expert] }

      it 'returns http success and send email' do
        scheduled = Sidekiq::ScheduledSet.new
        request

        expect(response).to be_successful
        expect(match.reload.status_taking_care?).to be true
        expect(scheduled.size).to eq 1
        expect(scheduled.first.queue).to eq 'match_notify'
      end
    end

    context 'current_user is an admin and not include in match.experts' do
      login_admin

      it 'returns http success and don’t send email' do
        scheduled = Sidekiq::ScheduledSet.new
        request

        expect(response).to be_successful
        expect(match.reload.status_taking_care?).to be true
        expect(scheduled.size).to eq 0
      end
    end
  end
end
