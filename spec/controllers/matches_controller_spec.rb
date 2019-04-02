require 'rails_helper'

RSpec.describe MatchesController, type: :controller do
  describe 'PATCH #update' do
    subject(:request) { patch :update, xhr: true, params: params }

    let(:params) { { id: match_id, access_token: access_token } }

    let(:match_id) { match.id }
    let(:access_token) { nil }

    context 'current user is an expert' do
      let(:match) { create :match, :with_expert_skill }

      let(:access_token) { expert.access_token }
      let(:expert) { create :expert }

      context 'access token is empty' do
        let(:access_token) { 'nil' }

        it('raises error') { expect { request }.to raise_error ActionController::RoutingError }
      end

      context 'match does not exist' do
        let(:match_id) { 'nonexisting' }

        it('raises error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
      end

      context 'match is not available to expert' do
        it('raises error') { expect { request }.to raise_error ActionController::RoutingError }
      end

      context 'match exists' do
        let(:expert_skill) { create :expert_skill, expert: expert }

        before { match.update expert_skill: expert_skill }

        context 'with status quo' do
          it 'returns http success' do
            params[:status] = :quo
            request

            expect(response).to be_successful
            expect(match.reload.status_quo?).to eq true
          end
        end

        context 'with status taking_care' do
          it 'returns http success' do
            params[:status] = :taking_care
            request

            expect(response).to be_successful
            expect(match.reload.status_taking_care?).to eq true
          end
        end
      end
    end
  end
end
