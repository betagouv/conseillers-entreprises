# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conseiller::SharedSatisfactionsController do
  login_user

  describe 'index pages' do
    let(:expert) { create :expert, users: [current_user] }
    let(:need1) { create :need, matches: [ create(:match, status: :done, expert: expert) ] }
    let(:need2) { create :need, matches: [ create(:match, status: :done, expert: expert) ] }
    let(:need3) { create :need, matches: [ create(:match, status: :done, expert: expert) ] }
    let(:company_satisfaction1) { create :company_satisfaction, need: need1 }
    let(:company_satisfaction2) { create :company_satisfaction, need: need2 }
    let(:company_satisfaction3) { create :company_satisfaction, need: need3 }

    let!(:seen_satisfaction_1) { create :shared_satisfaction, company_satisfaction: company_satisfaction1, user: current_user, seen_at: Time.zone.now }
    let!(:seen_satisfaction_2) { create :shared_satisfaction, company_satisfaction: company_satisfaction2, user: current_user, seen_at: Time.zone.now }
    let!(:unseen_satisfaction) { create :shared_satisfaction, company_satisfaction: company_satisfaction3, user: current_user, seen_at: nil }
    let!(:other_unseen_satisfaction) { create :shared_satisfaction, seen_at: nil }

    describe 'GET #index' do
      it 'redirects to unseen satisfactions' do
        get :index
        expect(request).to redirect_to(unseen_conseiller_shared_satisfactions_path)
      end
    end

    describe 'GET #unseen' do
      subject(:request) { get :unseen }

      before { request }

      it { expect(assigns(:needs)).to contain_exactly(unseen_satisfaction.company_satisfaction.need) }
    end

    describe 'GET #seen' do
      subject(:request) { get :seen }

      before { request }

      it { expect(assigns(:needs)).to contain_exactly(seen_satisfaction_1.company_satisfaction.need, seen_satisfaction_2.company_satisfaction.need) }
    end

    describe 'PATCH #mark_as_seen' do
      subject(:request) { patch :mark_as_seen, params: { id: unseen_satisfaction.id } }

      before { request }

      it { expect(response).to redirect_to(unseen_conseiller_shared_satisfactions_path) }
      it { expect(expert.shared_satisfactions.unseen.size).to eq(0) }

    end

  end

end
