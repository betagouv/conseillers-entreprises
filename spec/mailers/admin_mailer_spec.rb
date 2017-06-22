# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe AdminMailer do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe '#new_user_created_notification' do
    subject(:mail) { described_class.new_user_created_notification(user).deliver_now }

    let(:user) { create :user }

    it_behaves_like 'an email'

    it { expect(mail.from).to eq AdminMailer::SENDER }
  end
end
