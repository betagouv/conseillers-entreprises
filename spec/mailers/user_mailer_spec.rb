# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe UserMailer do
  describe '#send_new_user_invitation' do
    subject(:mail) { described_class.send_new_user_invitation(user_params).deliver_now }

    let(:user) { build :user }
    let(:user_params) { { first_name: user.first_name, email: user.email } }

    it_behaves_like 'an email'

    it { expect(mail.from).to eq UserMailer::SENDER }
  end

  describe '#account_approved' do
    subject(:mail) { described_class.account_approved(user).deliver_now }

    let(:user) { create :user }

    it_behaves_like 'an email'

    it { expect(mail.from).to eq UserMailer::SENDER }
  end

  describe '#yesterday_modifications' do
    subject(:mail) { described_class.yesterday_modifications(user, yesterday_modifications).deliver_now }

    let(:user) { create :user }
    let(:yesterday_modifications) { [] }

    it_behaves_like 'an email'

    it { expect(mail.from).to eq UserMailer::SENDER }
  end
end
