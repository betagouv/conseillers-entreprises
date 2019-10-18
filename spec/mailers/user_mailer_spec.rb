# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe UserMailer do
  describe '#account_approved' do
    subject(:mail) { described_class.account_approved(user).deliver_now }

    let(:user) { create :user }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq UserMailer::SENDER }
  end

  describe '#daily_change_update' do
    subject(:mail) { described_class.daily_change_update(user, change_updates).deliver_now }

    let(:user) { create :user }
    let(:change_updates) { [] }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq UserMailer::SENDER }
  end
end
