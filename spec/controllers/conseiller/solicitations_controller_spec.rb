# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conseiller::SolicitationsController do
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

        subject(:request) { get :index, params: { omnisearch: 'avis équipe' } }

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

    it { expect(solicitation.badges).to contain_exactly(badge) }
  end

  describe 'PATCH #mark_as_spam' do
    let(:email) { Faker::Internet.email }
    let(:solicitation) { create :solicitation, email: email, status: 'in_progress' }

    before { patch :mark_as_spam, params: { id: solicitation.id } }

    it 'marks solicitation as spam' do
      request
      expect(solicitation.reload.status).to eq("canceled")
      expect(solicitation.badges.pluck(:title)).to include('Spam')
    end
  end
end
