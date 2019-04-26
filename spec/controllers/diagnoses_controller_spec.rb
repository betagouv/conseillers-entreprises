# frozen_string_literal: true

require 'rails_helper'
RSpec.describe DiagnosesController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:archived_diagnosis) { create :diagnosis, :archived, advisor: advisor }
  let(:advisor) { current_user }

  describe 'GET #index' do
    subject(:request) { get :index }

    before do
      diagnosis
      archived_diagnosis
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'generates the active diagnoses list' do
      request
      expect(assigns(:diagnoses)).to contain_exactly(diagnosis)
    end
  end

  describe 'GET #archived' do
    subject(:request) { get :archives }

    before do
      diagnosis
      archived_diagnosis
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'generates the archived diagnoses list' do
      request
      expect(assigns(:diagnoses)).to contain_exactly(archived_diagnosis)
    end
  end

  describe 'GET #step2' do
    subject(:request) { get :step2, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'GET #step3' do
    subject(:request) { get :step3, params: { id: diagnosis.id } }

    context 'diagnosis step < last' do
      it('returns http success') { expect(response).to be_successful }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'GET #step4' do
    subject(:request) { get :step4, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end

    context 'current user should not access the diagnosis' do
      let(:advisor) { create :user }

      it('returns not found') { expect { request }.to raise_error ActionController::RoutingError }
    end
  end

  describe 'POST #selection' do
    before do
      allow_any_instance_of(Diagnosis).to receive(:match_and_notify!).and_return(result)
      post :selection, params: { id: diagnosis.id, matches: { 'a': { 'a': '1' } } }
    end

    context 'match_and_notify! succeeds' do
      let(:result) { true }

      it('redirects to the besoins page') { expect(response).to redirect_to besoin_path(diagnosis) }
    end

    context 'match_and_notify! fails' do
      let(:result) { false }

      it('fails') { expect(response).not_to be_successful }
    end
  end

  describe 'DELETE #destroy' do
    before { delete :destroy, params: { id: diagnosis.id } }

    it('redirects to index') { expect(response).to redirect_to diagnoses_path }
    it('destroys the diagnosis') { expect(Diagnosis.archived(false).count).to eq 0 }
  end
end
