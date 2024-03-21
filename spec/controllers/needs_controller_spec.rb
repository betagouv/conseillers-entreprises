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

  describe '#add_expert' do
    let(:need) { create(:need) }
    let(:request) { post :add_match, params: { id: need.id, expert_id: expert_id, format: :js } }

    context 'when user is admin and expert is present' do
      login_admin
      let(:expert) { create(:expert) }
      let(:expert_id) { expert.id }

      it 'adds an expert to the need' do
        request
        expect(response).to have_http_status(:success)
        expect(need.experts).to include(expert)
      end
    end

    context 'when user is admin and expert is not present' do
      login_admin
      let(:expert_id) { '' }

      it 'does not add an expert if expert_id is nil' do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(need.experts).to be_empty
      end
    end

    context 'when user is not admin' do
      login_user
      let(:expert) { create(:expert) }
      let(:expert_id) { expert.id }

      it 'does not add an expert' do
        expect { request }.to raise_error(Pundit::NotAuthorizedError)
        expect(need.experts).not_to include(expert)
      end
    end
  end
end
