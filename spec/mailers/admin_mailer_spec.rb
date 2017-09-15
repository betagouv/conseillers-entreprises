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

  describe '#new_user_approved_notification' do
    subject(:mail) { described_class.new_user_approved_notification(user, admin).deliver_now }

    let(:user) { create :user }
    let(:admin) { create :user }

    it_behaves_like 'an email'

    it { expect(mail.from).to eq AdminMailer::SENDER }
  end

  describe '#weekly_statistics' do
    subject(:mail) { described_class.weekly_statistics(information_hash).deliver_now }

    let(:information_hash) do
      user = create :user
      visit = create :visit
      {
        signed_up_users: { count: 1, items: [user] },
        visits: [{ user: user, visits_count: 1 }],
        diagnoses: [{ visit: visit, diagnoses_count: 1 }]
      }
    end

    it_behaves_like 'an email'

    it { expect(mail.from).to eq AdminMailer::SENDER }
  end
end
