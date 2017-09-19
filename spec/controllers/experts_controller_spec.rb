# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExpertsController, type: :controller do
  let(:diagnosis) { create :diagnosis }

  describe 'GET #diagnosis' do
    subject(:request) { get :diagnosis, params: { diagnosis_id: diagnosis.id, access_token: access_token } }

    context 'access token is empty' do
      let(:access_token) { nil }

      it('raises error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'access token exists' do
      let(:access_token) { expert.access_token }
      let(:expert) { create :expert }

      context 'expert has access to diagnosis' do
        let(:assistance_expert) { create :assistance_expert, expert: expert }
        let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

        before do
          create :selected_assistance_expert, assistance_expert: assistance_expert, diagnosed_need: diagnosed_need
        end

        it 'returns http success' do
          request

          expect(response).to have_http_status(:success)
        end
      end

      context 'expert does not have access to diagnosis' do
        it('raises error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
      end
    end
  end
end
