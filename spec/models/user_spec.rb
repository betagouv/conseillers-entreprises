# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:first_name)
        is_expected.to validate_presence_of(:last_name)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:phone_number)
      end
    end

    describe 'emails' do
      it do
        is_expected.to validate_presence_of(:email)
        is_expected.to allow_value('test@beta.gouv.fr').for(:email)
        is_expected.not_to allow_value('test').for(:email)
      end
    end

    describe 'passwords' do
      it do
        is_expected.to validate_presence_of(:password)
        is_expected.not_to allow_value('short').for(:password)
      end
    end
  end

  describe 'scopes' do
    describe 'for_contact_page' do
      it do
        create :user, contact_page_order: nil
        user_of_contact_page = create :user, contact_page_order: 1

        expect(User.for_contact_page).to eq [user_of_contact_page]
      end
    end

    describe 'not_admin' do
      it do
        create :user, is_admin: true
        regular_user = create :user, is_admin: false

        expect(User.not_admin).to eq [regular_user]
      end
    end
  end

  describe 'full_name' do
    let(:user) { build :user, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(user.full_name).to eq 'Ivan Collombet' }
  end

  describe 'full_name_with_role' do
    let(:user) do
      build :user,
            first_name: 'Ivan',
            last_name: 'Collombet',
            role: 'Business Developer',
            institution: 'SGMAP'
    end

    it { expect(user.full_name_with_role).to eq 'Ivan Collombet, Business Developer, SGMAP' }
  end

  describe 'send_admin_mail' do
    let(:mail) { Mail::Message.new }

    before do
      allow(AdminMailer).to receive(:new_user_created_notification).and_return(mail)
      allow(mail).to receive(:deliver)
    end

    context 'user is not approved' do
      it 'warns admins' do
        create :user, is_approved: false
        expect(AdminMailer).to have_received(:new_user_created_notification)
        expect(mail).to have_received(:deliver)
      end
    end

    context 'user is not approved' do
      it 'does not warn admins' do
        create :user, is_approved: true
        expect(AdminMailer).not_to have_received(:new_user_created_notification)
      end
    end
  end
end
