# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conseiller::SolicitationsController, type: :controller do
  login_admin

  describe 'index pages' do
    let!(:step_company) { create :solicitation, status: :step_company }
    let!(:step_description) { create :solicitation, status: :step_description, description: nil }
    let!(:in_progress) { create :solicitation, status: :in_progress }
    # solicitation in progress with feedback
    let!(:feedback) { create :feedback, :for_solicitation }
    let!(:processed) { create :solicitation, status: :processed }
    let!(:canceled) { create :solicitation, status: :canceled }

    describe 'GET #index' do
      context 'without search params' do
        subject(:request) { get :index }

        before { request }

        it { expect(assigns(:solicitations)).to contain_exactly(in_progress, feedback.solicitation) }
      end

      context 'with search params' do
        let(:badge) { create(:badge, title: 'avis équipe') }
        let!(:solicitation_with_badge) { create(:solicitation, status: :in_progress, badges: [badge]) }

        subject(:request) { get :index, params: { query: 'avis équipe' } }

        before { request }

        it { expect(assigns(:solicitations)).to contain_exactly(solicitation_with_badge) }
      end
    end

    describe 'GET #processed' do
      subject(:request) { get :processed }

      before { request }

      it { expect(assigns(:solicitations)).to contain_exactly(processed) }
    end

    describe 'GET #canceled' do
      subject(:request) { get :canceled }

      before { request }

      it { expect(assigns(:solicitations)).to contain_exactly(canceled) }
    end
  end

  describe 'POST #update_badges' do
    let!(:solicitation) { create(:solicitation) }
    let!(:badge) { create(:badge) }

    subject(:request) { post :update_badges, params: { id: solicitation.id, solicitation: { badge_ids: [badge.id] } }, format: :js }

    before { request }

    it { expect(solicitation.badges).to match_array([badge]) }
  end
end
