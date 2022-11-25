require 'rails_helper'

RSpec.describe NeedsController do
  login_user

  describe 'needs inboxes' do
    describe 'GET #index' do
      subject(:request) { get :index }

      it 'returns http success' do
        expect(response).to be_successful
      end
    end

    describe 'GET #archives' do
      subject(:request) { get :archives }

      it 'returns http success' do
        expect(response).to be_successful
      end
    end
  end

  describe 'GET #show' do
    subject(:request) { get :show, params: { id: diagnosis.id } }

    let(:diagnosis) { create :diagnosis }

    context 'current user is an expert' do
      let!(:expert) { create :expert, users: [current_user] }

      context 'user is contacted for diagnosis' do
        before do
          create(:match,
                 expert: expert,
                 need: create(:need,
                              diagnosis: diagnosis))
        end

        it('returns http success') { expect(response).to be_successful }
      end
    end
  end
end
