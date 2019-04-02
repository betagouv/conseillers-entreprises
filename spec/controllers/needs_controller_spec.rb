require 'rails_helper'

RSpec.describe NeedsController, type: :controller do
  login_user

  describe 'GET #show' do
    subject(:request) { get :show, params: { id: diagnosis.id } }

    let(:diagnosis) { create :diagnosis }

    context 'current user is an expert' do
      let!(:expert_skill) { create :expert_skill, expert: create(:expert, users: [current_user]) }

      context 'user is not contacted for diagnosis' do
        it('raises error') { expect { request }.to raise_error ActionController::RoutingError }
      end

      context 'user is contacted for diagnosis' do
        before do
          create(:match,
            expert_skill: expert_skill,
            need: create(:need,
              diagnosis: diagnosis))
        end

        it('returns http success') { expect(response).to be_successful }
      end
    end
  end
end
