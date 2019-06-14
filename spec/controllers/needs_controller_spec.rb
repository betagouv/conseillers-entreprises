require 'rails_helper'

RSpec.describe NeedsController, type: :controller do
  login_user

  describe 'needs inboxes' do
    let(:current_expert) { create :expert, users: [current_user] }
    let(:other_expert) { create :expert }

    let!(:need_taking_care) do
      create(:need, matches: [create(:match, expert: current_expert, status: :taking_care)])
    end
    let!(:need_quo) do
      create(:need, matches: [create(:match, expert: current_expert, status: :quo)])
    end
    let!(:need_rejected) do
      create(:need, matches: [create(:match, expert: current_expert, status: :not_for_me)])
    end
    let!(:need_done) do
      create(:need, matches: [create(:match, expert: current_expert, status: :done)])
    end
    let!(:need_archived) do
      create(:need, matches: [create(:match, expert: current_expert, status: :quo)], archived_at: Time.zone.now)
    end
    let!(:need_other_taking_care) do
      create(:need, matches: [
        create(:match, expert: current_expert, status: :quo),
        create(:match, expert: other_expert, status: :taking_care)
      ])
    end

    describe 'GET #index' do
      subject(:request) { get :index }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'generates the active diagnoses list' do
        request
        expect(assigns(:needs_taking_care)).to contain_exactly(need_taking_care)
        expect(assigns(:needs_quo)).to contain_exactly(need_quo)
        expect(assigns(:needs_others_taking_care)).to contain_exactly(need_other_taking_care)
      end
    end

    describe 'GET #archives' do
      subject(:request) { get :archives }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'generates the active diagnoses list' do
        request
        expect(assigns(:needs_rejected)).to contain_exactly(need_rejected)
        expect(assigns(:needs_done)).to contain_exactly(need_done)
        expect(assigns(:needs_archived)).to contain_exactly(need_archived)
      end
    end
  end

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
