# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExpertsController, type: :controller do
  describe 'GET #diagnosis' do
    subject(:request) { get :diagnosis, params: { diagnosis_id: diagnosis.id, access_token: access_token } }

    let(:diagnosis) { create :diagnosis }

    context 'access token is empty' do
      let(:access_token) { nil }

      it('raises error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'access token exists' do
      let(:access_token) { expert.access_token }
      let(:expert) { create :expert }

      let(:assistance_expert) { create :assistance_expert, expert: expert }
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

      before do
        allow(UseCases::UpdateExpertViewedPageAt).to receive(:perform).with(
          diagnosis: diagnosis,
          expert: expert
        )
      end

      context 'expert has access to diagnosis' do
        before do
          create :match, assistance_expert: assistance_expert, diagnosed_need: diagnosed_need
          request
        end

        it('returns http success') { expect(response).to be_successful }
      end

      context 'archived diagnosis' do
        before do
          diagnosis.archive!

          create :match, assistance_expert: assistance_expert, diagnosed_need: diagnosed_need
          request
        end

        it('returns http success') { expect(response).to be_successful }
      end

      context 'expert does not have access to diagnosis' do
        it('raises error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
      end
    end
  end
end
