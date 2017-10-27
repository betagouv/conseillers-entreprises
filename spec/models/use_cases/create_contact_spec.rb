# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateContact do
  describe 'create_for_visit' do
    subject(:create_for_visit) { described_class.create_for_visit(contact_params: contact_params, visit_id: visit_id) }

    let(:facility) { create :facility }
    let(:visit) { create :visit, facility: facility }
    let(:visit_id) { visit.id }

    let(:contact_params) do
      {
        full_name: 'Gérard Pardessus',
        email: 'g.pardessus@looser.com',
        phone_number: nil,
        role: 'looser'
      }
    end

    context 'when parameters are OK' do
      it 'creates a contact for the selected company' do
        create_for_visit

        expect(facility.company.contacts.count).to eq(1)
        expect(facility.company.contacts.first.full_name).to eq('Gérard Pardessus')
        expect(facility.company.contacts.first.email).to eq('g.pardessus@looser.com')
        expect(facility.company.contacts.first.phone_number).to be_nil
        expect(facility.company.contacts.first.role).to eq('looser')
      end

      it('adds the contact to the visit') do
        return_value = create_for_visit

        expect(return_value).to eq(facility.company.contacts.first)
        expect(visit.reload.visitee).to eq(facility.company.contacts.first)
      end
    end

    context 'when parameters are missing' do
      let(:contact_params) { { full_name: 'Gérard Pardessus' } }

      it('throws an error') { expect { create_for_visit }.to raise_error ActiveRecord::RecordInvalid }
    end

    context 'when visit does not exist' do
      let(:visit_id) { visit.id + 1 }

      it('throws an error') { expect { create_for_visit }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end
