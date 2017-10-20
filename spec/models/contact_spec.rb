# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :company
      is_expected.to have_many(:visits).dependent(:restrict_with_error)
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:last_name)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:company)
      end
    end

    describe 'email format' do
      it do
        is_expected.to allow_value('test@beta.gouv.fr').for(:email)
        is_expected.to allow_value('0_@1-.2').for(:email)
        is_expected.not_to allow_value('test').for(:email)
        is_expected.not_to allow_value('te@st').for(:email)
      end
    end

    describe 'phone number format' do
      it do
        is_expected.to allow_value('06 12 23 45 67').for(:phone_number)
        is_expected.to allow_value('06.12.23.45.67').for(:phone_number)
        is_expected.to allow_value('+33612234567').for(:phone_number)
        is_expected.not_to allow_value('06 12 23').for(:phone_number)
        is_expected.not_to allow_value('06.12.23').for(:phone_number)
        is_expected.not_to allow_value('+336122ab34567').for(:phone_number)
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

  describe 'can_be_viewed_by?' do
    subject { contact.can_be_viewed_by?(user) }

    let(:user) { create :user }
    let(:contact) { create :contact, :with_email }

    before do
      create :visit, advisor: advisor
      create :visit, advisor: advisor, visitee: contact
    end

    context 'visit advisor is the user' do
      let(:advisor) { user }

      it { is_expected.to eq true }
    end

    context 'visit advisor is not the user' do
      let(:advisor) { create :user }

      it { is_expected.to eq false }
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

  describe 'to_s' do
    let(:contact) { build :contact, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(contact.to_s).to eq 'Ivan Collombet' }
  end
end
