# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Api::ContactsController, type: :controller do
  login_user

  describe 'GET #index' do
    subject(:request) { get :index, format: :json, params: { visit_id: visit.id } }

    context 'when visit exists' do
      let(:contact) { create :contact, :with_email }
      let(:visit) { create :visit, visitee: contact }

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
    subject(:request) do
      post :create,
           format: :json,
           params: {
             visit_id: visit.id,
             contact: contact_params
           }
    end

    let(:facility) { create :facility }
    let(:visit) { create :visit, facility: facility }

    context 'when parameters are OK' do
      let(:contact_params) do
        {
          full_name: 'Gérard Pardessus',
          email: 'g.pardessus@looser.com',
          phone_number: nil,
          role: 'looser'
        }
      end

      before { request }

      it 'returns http success' do
        expect(response).to have_http_status(:created)
      end

      it 'creates a contact for the selected company' do
        expect(facility.company.contacts.count).to eq(1)
        expect(facility.company.contacts.first.full_name).to eq('Gérard Pardessus')
        expect(facility.company.contacts.first.email).to eq('g.pardessus@looser.com')
        expect(facility.company.contacts.first.phone_number).to eq('')
        expect(facility.company.contacts.first.role).to eq('looser')
      end

      it 'adds the contact to the visit' do
        expect(visit.reload.visitee).to eq(facility.company.contacts.first)
      end
    end

    context 'when parameters are missing' do
      let(:contact_params) do
        {
          full_name: 'Gérard Pardessus'
        }
      end

      before { request }

      it 'returns http bad request' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a contact' do
        expect(facility.company.contacts.count).to eq 0
      end
    end

    context 'when visit does not exist' do
      let(:visit) { build :visit }
      let(:contact_params) { nil }

      it 'raises an error' do
        expect { request }.to raise_error ActionController::UrlGenerationError
      end
    end
  end

  describe 'PATCH #update' do
    subject(:request) do
      patch :update,
            format: :json,
            params: {
              id: contact.id,
              contact: contact_params
            }
    end

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

      before { request }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates the diagnosis s content' do
        reloaded_contact = contact.reload
        expect(reloaded_contact.full_name).to eq new_contact.full_name
        expect(reloaded_contact.email).to eq new_contact.email
        expect(reloaded_contact.phone_number).to eq new_contact.phone_number
        expect(reloaded_contact.role).to eq new_contact.role
      end
    end

    context 'when parameters are wrong' do
      let(:contact_params) do
        {
          email: '',
          role: ''
        }
      end

      before { request }

      it 'returns http bad request' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'updates the diagnosis s content' do
        expect(contact.reload.full_name).to eq(contact.full_name)
      end
    end

    context 'when contact does not exist' do
      let(:contact) { build :contact }
      let(:contact_params) { nil }

      it 'raises an error' do
        expect { request }.to raise_error ActionController::UrlGenerationError
      end
    end
  end

  describe 'GET #destroy' do
    subject(:request) do
      delete :destroy,
             format: :json,
             params: {
               id: contact.id
             }
    end

    context 'when contact exists' do
      let(:company) { create :company }
      let(:contact) { build :contact, :with_email, company: company }

      before { contact.save }

      context 'when contact can be destroyed' do
        it 'returns http ok' do
          request

          expect(response).to have_http_status(:ok)
        end

        it 'destroys the contact' do
          expect { request }.to change(Contact, :count).by(-1)
        end
      end

      context 'when contact cannot be destroyed' do
        before { create :visit, visitee: contact }

        it 'returns http bad request' do
          request

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not destroy the contact' do
          expect { request }.not_to change(Contact, :count)
        end
      end
    end

    context 'when contact does not exist' do
      let(:contact) { build :contact }

      it 'raises an error' do
        expect { request }.to raise_error ActionController::UrlGenerationError
      end
    end
  end

  describe 'GET #contact_button_expert' do
    subject(:request) do
      get :contact_button_expert,
          format: :json,
          params: {
            visit_id: visit.id,
            assistance_id: assistance.id,
            expert_id: expert.id
          }
    end

    context 'when visit exists' do
      let(:visit) { create :visit }

      context 'when assistance exists' do
        let(:assistance) { create :assistance, :with_expert }
        let(:expert) { assistance.experts.first }

        it('returns http success') do
          request

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when assistance does not exist' do
        let(:assistance) { build :assistance, :with_expert }
        let(:expert) { create :expert }

        it('raises an error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
      end
    end

    context 'when visit does not exist' do
      let(:visit) { build :visit }
      let(:assistance) { create :assistance, :with_expert }
      let(:expert) { create :expert }

      it('raises an error') { expect { request }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end
# rubocop:enable Metrics/BlockLength
