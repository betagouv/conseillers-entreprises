# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  login_user

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit_visitee' do
    it 'returns http success' do
      visit = create :visit
      get :show, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'save worked' do
      it 'redirects to the show page' do
        siret = '12345678901234'
        company = create :company, siren: siret[0, 9]
        allow(UseCases::SearchCompany).to receive(:with_siret_and_save).with(siret) { company }
        post :create, params: { visit: { siret: siret, happened_at: 1.day.from_now } }
        is_expected.to redirect_to visit_path(Visit.last)
      end
    end

    context 'saved failed' do
      it 'does not redirect' do
        allow(UseCases::SearchCompany).to receive(:with_siret_and_save)
        post :create, params: { visit: { happened_at: 1.day.from_now } }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #edit_visitee' do
    it 'returns http success' do
      visit = create :visit
      get :edit_visitee, params: { id: visit.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update_visitee' do
    subject { patch :update_visitee, params: { id: visit.id, visit: { visitee_attributes: visitee_attributes }, question_id: question_id } }

    let(:visit) { create :visit }
    let(:user) { build :user }
    let(:question_id) { nil }

    context 'save worked' do
      let(:visitee_attributes) { { full_name: user.full_name, email: user.email, role: user.role, phone_number: user.phone_number } }

      context 'there is no question_id' do
        it 'redirects to the visit list' do
          is_expected.to redirect_to visit_path(visit)
        end
      end

      context 'there is a question_id' do
        let(:question) { create :question }
        let(:question_id) { question.id }

        it 'redirects to the question page' do
          is_expected.to redirect_to question_visit_diagnosis_index_path(id: question_id, visit_id: visit.id)
        end
      end
    end

    context 'saved failed' do
      let(:visitee_attributes) { { full_name: user.full_name } }

      it 'does not redirect' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
