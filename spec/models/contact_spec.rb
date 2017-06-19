# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:last_name)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:company)
      end
    end

    describe 'email or phone_number' do
      context 'without any contact type' do
        it do
          contact = build :contact
          expect(contact).not_to be_valid
        end
      end

      context 'with email' do
        it do
          contact = build :contact, :with_email
          expect(contact).to be_valid
        end
      end

      context 'with phone number' do
        it do
          contact = build :contact, :with_phone_number
          expect(contact).to be_valid
        end
      end
    end
  end

  describe 'full_name=' do
    subject(:set_full_name) { contact.full_name = full_name }

    let(:contact) { build :contact, first_name: nil, last_name: nil }

    context 'when full name has two words' do
      let(:full_name) { 'Ivan Collombet' }

      it do
        set_full_name
        expect(contact.first_name).to eq 'Ivan'
        expect(contact.last_name).to eq 'Collombet'
      end
    end

    context 'when full name has several words' do
      let(:full_name) { 'Ivan Collombet De La Haute Cour' }

      it do
        set_full_name
        expect(contact.first_name).to eq 'Ivan'
        expect(contact.last_name).to eq 'Collombet De La Haute Cour'
      end
    end

    context 'when full name has one word' do
      let(:full_name) { 'Collombet' }

      it do
        set_full_name
        expect(contact.first_name).to be_nil
        expect(contact.last_name).to eq 'Collombet'
      end
    end

    context 'when full name is empty' do
      let(:full_name) { '' }

      it do
        set_full_name
        expect(contact.first_name).to be_nil
        expect(contact.last_name).to be_nil
      end
    end

    context 'when full name is nil' do
      let(:full_name) { nil }

      it do
        set_full_name
        expect(contact.first_name).to be_nil
        expect(contact.last_name).to be_nil
      end
    end
  end

  describe 'full_name' do
    let(:contact) { build :contact, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(contact.full_name).to eq 'Ivan Collombet' }
  end
end
