# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:last_name)
        is_expected.to validate_presence_of(:institution)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:phone_number)
        is_expected.to validate_presence_of(:password)
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

  describe 'full_name=' do
    subject(:set_full_name) { user.full_name = full_name }

    let(:user) { build :user, first_name: nil, last_name: nil }

    context 'when full name has two words' do
      let(:full_name) { 'Ivan Collombet' }

      it do
        set_full_name
        expect(user.first_name).to eq 'Ivan'
        expect(user.last_name).to eq 'Collombet'
      end
    end

    context 'when full name has several words' do
      let(:full_name) { 'Ivan Collombet De La Haute Cour' }

      it do
        set_full_name
        expect(user.first_name).to eq 'Ivan'
        expect(user.last_name).to eq 'Collombet De La Haute Cour'
      end
    end

    context 'when full name has one word' do
      let(:full_name) { 'Collombet' }

      it do
        set_full_name
        expect(user.first_name).to be_nil
        expect(user.last_name).to eq 'Collombet'
      end
    end

    context 'when full name is empty' do
      let(:full_name) { '' }

      it do
        set_full_name
        expect(user.first_name).to be_nil
        expect(user.last_name).to be_nil
      end
    end

    context 'when full name is nil' do
      let(:full_name) { nil }

      it do
        set_full_name
        expect(user.first_name).to be_nil
        expect(user.last_name).to be_nil
      end
    end
  end

  describe 'full_name' do
    let(:user) { build :user, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(user.full_name).to eq 'Ivan Collombet' }
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

    context 'user is not approved but is added by an advisor' do
      it 'does not warn admins' do
        create :user, is_approved: false, added_by_advisor: true
        expect(AdminMailer).not_to have_received(:new_user_created_notification)
      end
    end
  end
end
