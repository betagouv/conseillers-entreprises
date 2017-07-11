# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ContactsController, type: :controller do
  login_user

  # let(:visit) { create :visit, advisor: current_user }
  # let(:diagnosis) { create :diagnosis, visit: visit, content: Faker::Lorem.paragraph }

  let(:contact) { create :contact, :with_email }

  describe 'GET #show' do
    before { get :show, format: :json, params: { id: contact.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #index' do
    let(:visit) { create :visit, visitee: contact }

    before { get :index, format: :json, params: { visit_id: visit.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:facility) { create :facility }
    let(:visit) { create :visit, facility: facility }

    before do
      post :create,
           format: :json,
           params: {
             visit_id: visit.id,
             contact: {
               full_name: 'Gérard Pardessus',
               email: 'g.pardessus@looser.com',
               phone_number: nil,
               role: 'looser'
             }
           }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'creates a contact for the selected company' do
      expect(facility.company.contacts.count).to eq(1)
      expect(facility.company.contacts.first.full_name).to eq('Gérard Pardessus')
      expect(facility.company.contacts.first.email).to eq('g.pardessus@looser.com')
      expect(facility.company.contacts.first.phone_number).to eq('')
      expect(facility.company.contacts.first.role).to eq('looser')
    end
  end

  describe 'PATCH #update' do
    let(:new_name) { 'Monsieur Pardessus' }
    let(:contact) { create :contact, :with_email }

    before do
      patch :update,
            format: :json,
            params: {
              id: contact.id,
              contact: {
                full_name: new_name
              }
            }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'updates the diagnosis s content' do
      expect(contact.reload.full_name).to eq(new_name)
    end
  end

  describe 'GET #destroy' do
    let(:company) { create :company }
    let(:contact) { create :contact, :with_email, company: company }

    before do
      delete :destroy,
             format: :json,
             params: {
               id: contact.id
             }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:no_content)
    end

    it 'destroys the contact' do
      expect(company.contacts.count).to eq(0)
    end
  end

  describe 'GET #contact_button_expert' do
    let(:visit) { create :visit }
    let(:assistance) { create :assistance, :with_expert }

    before do
      get :contact_button_expert,
          format: :json,
          params: {
            visit_id: visit.id,
            assistance_id: assistance.id,
            expert_id: assistance.experts.first.id
          }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end
end
