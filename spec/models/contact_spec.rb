require 'rails_helper'

RSpec.describe Contact do
  describe 'associations' do
    it do
      is_expected.to have_many(:diagnoses).dependent(:restrict_with_error)
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
      end
    end

    describe 'email uniqueness' do
      let!(:existing) { create :contact, email: 'shared@example.com' }

      context 'same email' do
        it 'is invalid' do
          duplicate = build :contact, email: 'shared@example.com'
          expect(duplicate).not_to be_valid
          expect(duplicate.errors[:email]).to be_present
        end
      end

      context 'blank email' do
        it 'is valid (allow_blank)' do
          create :contact, :with_phone_number, email: nil
          other = build :contact, :with_phone_number, email: nil
          expect(other).to be_valid
        end
      end
    end

    describe 'email or phone_number' do
      context 'without any contact type' do
        it do
          contact = build :contact, email: nil
          expect(contact).not_to be_valid
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

  describe 'to_s' do
    let(:contact) { build :contact, full_name: 'Ivan Collombet' }

    it { expect(contact.to_s).to eq 'Ivan Collombet' }
  end
end
