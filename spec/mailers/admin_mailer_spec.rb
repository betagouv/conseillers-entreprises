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
      diagnoses = create_list :diagnosis, 2
      {
        signed_up_users: { count: 1, items: [user] },
        created_diagnoses: { count: 2, items: diagnoses },
        updated_diagnoses: { count: 2, items: diagnoses },
        completed_diagnoses: { count: 2, items: diagnoses },
        contacted_experts_count: 3
      }
    end

    it_behaves_like 'an email'

    it { expect(mail.from).to eq AdminMailer::SENDER }
  end
end
