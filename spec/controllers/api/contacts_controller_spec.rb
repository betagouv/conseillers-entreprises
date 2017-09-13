# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ContactsController, type: :controller do
  login_user

  describe 'GET #index' do
    subject(:request) { get :index, format: :json, params: { visit_id: visit.id } }

    context 'when visit exists' do
      let(:contact) { create :contact, :with_email }
      let(:visit) { create :visit, advisor: current_user, visitee: contact }

      it 'returns http success' do
        request

        expect(response).to have_http_status(:success)
      end
    end

    context 'when visit does not exist' do
      let(:visit) { build :visit }

      it('raises an error') { expect { request }.to raise_error ActionController::UrlGenerationError }
    end
  end

  describe 'GET #show' do
    subject(:request) { get :show, format: :json, params: { id: contact.id } }

    context 'when contact exists' do
      let(:contact) { create :contact, :with_email }

      before { create :visit, advisor: current_user, visitee: contact }

      it 'returns http success' do
        request

        expect(response).to have_http_status(:success)
      end
    end

    context 'when contact does not exist' do
      let(:contact) { build :contact }

      it('raises an error') { expect { request }.to raise_error ActionController::UrlGenerationError }
    end
  end

  describe 'POST #create' do
    subject(:request) { post :create, format: :json, params: { visit_id: visit.id, contact: contact_params } }

    let(:facility) { create :facility }
    let(:visit) { create :visit, advisor: current_user, facility: facility }

    context 'when parameters are OK' do
      let(:contact_params) do
        { full_name: 'Gérard Pardessus', email: 'g.pardessus@looser.com', phone_number: nil, role: 'looser' }
      end

      before { request }

      it('returns http success') { expect(response).to have_http_status(:created) }

      it 'creates a contact for the selected company' do
        expect(facility.company.contacts.count).to eq(1)
        expect(facility.company.contacts.first.full_name).to eq('Gérard Pardessus')
        expect(facility.company.contacts.first.email).to eq('g.pardessus@looser.com')
        expect(facility.company.contacts.first.phone_number).to eq('')
        expect(facility.company.contacts.first.role).to eq('looser')
      end

      it('adds the contact to the visit') { expect(visit.reload.visitee).to eq(facility.company.contacts.first) }
    end

    context 'when parameters are missing' do
      let(:contact_params) { { full_name: 'Gérard Pardessus' } }

      before { request }

      it('returns http bad request') { expect(response).to have_http_status(:bad_request) }
      it('does not create a contact') { expect(facility.company.contacts.count).to eq 0 }
    end

    context 'when visit does not exist' do
      let(:visit) { build :visit }
      let(:contact_params) { nil }

      it('raises an error') { expect { request }.to raise_error ActionController::UrlGenerationError }
    end
  end

  describe 'PATCH #update' do
    subject(:request) { patch :update, format: :json, params: { id: contact.id, contact: contact_params } }

    let(:contact) { create :contact, :with_email }
    let(:new_contact) { build :contact, :with_email, :with_phone_number }

    context 'when parameters are OK' do
      let(:contact_params) do
        {
          full_name: new_contact.full_name,
          email: new_contact.email,
          phone_number: new_contact.phone_number,
          role: new_contact.role
        }
      end

      before do
        create :visit, advisor: current_user, visitee: contact
        request
      end

      it('returns http success') { expect(response).to have_http_status(:success) }

      it 'updates the diagnosis s content' do
        reloaded_contact = contact.reload
        expect(reloaded_contact.full_name).to eq new_contact.full_name
        expect(reloaded_contact.email).to eq new_contact.email
        expect(reloaded_contact.phone_number).to eq new_contact.phone_number
        expect(reloaded_contact.role).to eq new_contact.role
      end
    end

    context 'when parameters are wrong' do
      let(:contact_params) { { email: '', role: '' } }

      before do
        create :visit, advisor: current_user, visitee: contact
        request
      end

      it('returns http bad request') { expect(response).to have_http_status(:bad_request) }
      it('updates the diagnosis s content') { expect(contact.reload.full_name).to eq(contact.full_name) }
    end

    context 'when contact does not exist' do
      let(:contact) { build :contact }
      let(:contact_params) { nil }

      it('raises an error') { expect { request }.to raise_error ActionController::UrlGenerationError }
    end
  end
end
