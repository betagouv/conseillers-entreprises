require 'rails_helper'

RSpec.describe Contact do
  describe 'associations' do
    it do
      is_expected.to belong_to :company
      is_expected.to have_many(:diagnoses).dependent(:restrict_with_error)
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to belong_to(:company)
      end
    end

    describe 'email uniqueness per company' do
      let(:company) { create :company }
      let!(:existing) { create :contact, company: company, email: 'shared@example.com' }

      context 'same email in the same company' do
        it 'is invalid' do
          duplicate = build :contact, company: company, email: 'shared@example.com'
          expect(duplicate).not_to be_valid
          expect(duplicate.errors[:email]).to be_present
        end
      end

      context 'same email in a different company' do
        it 'is valid' do
          other = build :contact, email: 'shared@example.com'
          expect(other).to be_valid
        end
      end

      context 'blank email with same company' do
        it 'is valid (allow_blank)' do
          contact = build :contact, :with_phone_number, company: company, email: nil
          expect(contact).to be_valid
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
