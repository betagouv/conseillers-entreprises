# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Diagnoses::StepsController, type: :controller do
  login_user

  let(:diagnosis) { create :diagnosis, advisor: advisor }
  let(:advisor) { current_user }

  describe 'GET #besoins' do
    subject(:request) { get :besoins, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'GET #visite' do
    subject(:request) { get :visite, params: { id: diagnosis.id } }

    context 'diagnosis step < last' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'GET #selection' do
    subject(:request) { get :selection, params: { id: diagnosis.id } }

    context 'diagnosis' do
      it('returns http success') { expect(response).to be_successful }
    end
  end

  describe 'POST #selection' do
    let(:expert_subject) { create(:expert_subject) }
    let!(:need) { create(:need, diagnosis: diagnosis) }

    before do
      post :selection, params: { id: diagnosis.id, matches: { need.id => { expert_subject.id => '1' } } }
    end

    context 'match_and_notify! succeeds' do
      let(:result) { true }

      it('redirects to the besoins page') { expect(response).to redirect_to need_path(diagnosis) }
    end

    context 'match_and_notify! fails' do
      let(:result) { false }

      it('fails') { expect(response).not_to be_successful }
    end
  end
end
