# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateContact do
  describe 'create_for_visit' do
    let(:facility) { create :facility }
    let(:visit) { create :visit, facility: facility }

    context 'when parameters are OK' do
      return_value = nil
      let(:contact_params) do
        {
          full_name: 'Gérard Pardessus',
          email: 'g.pardessus@looser.com',
          phone_number: nil,
          role: 'looser'
        }
      end

      before do
        return_value = described_class.create_for_visit(contact_params: contact_params, visit_id: visit.id)
      end

      it 'creates a contact for the selected company' do
        expect(facility.company.contacts.count).to eq(1)
        expect(facility.company.contacts.first.full_name).to eq('Gérard Pardessus')
        expect(facility.company.contacts.first.email).to eq('g.pardessus@looser.com')
        expect(facility.company.contacts.first.phone_number).to be_nil
        expect(facility.company.contacts.first.role).to eq('looser')
      end

      it('adds the contact to the visit') do
        expect(visit.reload.visitee).to eq(facility.company.contacts.first)
      end

      it('returns the contact') do
        expect(return_value).to eq(facility.company.contacts.first)
      end
    end

    context 'when parameters are missing' do
      return_value = nil
      error = nil
      let(:contact_params) do
        {
          full_name: 'Gérard Pardessus'
        }
      end

      before do
        begin
          return_value = described_class.create_for_visit(contact_params: contact_params, visit_id: visit.id)
        rescue StandardError => e
          error = e
        end
      end

      it('returns nothing') { expect(return_value).to be_nil }
      it('does not create a contact') { expect(facility.company.contacts.count).to eq 0 }

      it('throws an error') do
        expect(error).to be_a ActiveRecord::RecordInvalid
      end
    end

    context 'when visit does not exist' do
      return_value = nil
      error = nil
      let(:contact_params) do
        {
          full_name: 'Gérard Pardessus',
          email: 'g.pardessus@looser.com',
          phone_number: nil,
          role: 'looser'
        }
      end

      before do
        begin
          return_value = described_class.create_for_visit(contact_params: contact_params,
                                                          visit_id: visit.id + 1)
        rescue StandardError => e
          error = e
        end
      end

      it('returns nothing') { expect(return_value).to be_nil }
      it('does not create a contact') { expect(facility.company.contacts.count).to eq 0 }

      it('throws an error') do
        expect(error).to be_a ActiveRecord::RecordNotFound
      end
    end
  end
end
