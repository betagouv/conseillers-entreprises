# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe AdminMailer do
  describe '#new_user_created_notification' do
    subject(:mail) { described_class.new_user_created_notification(user).deliver_now }

    let(:user) { create :user }

    context 'with default recipients' do
      let!(:admin) { create :user, is_admin: true }

      it_behaves_like 'an email'

      it do
        expect(mail.to).to eq [admin.email]
        expect(mail.from).to eq AdminMailer::SENDER
      end
    end

    context 'no default recipients' do
      it { expect { mail }.to raise_error AdminMailer::RecipientsExpectedError }
    end
  end
end
