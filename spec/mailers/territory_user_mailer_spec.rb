# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe TerritoryUserMailer do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe '#weekly_statistics' do
    subject(:mail) { described_class.weekly_statistics(territory_user, information_hash, stats_csv).deliver_now }

    let(:territory_user) { create :territory_user }
    let(:stats_csv) { CSV.generate { |line| line << %w[col_1 col_2] } }

    let(:information_hash) do
      diagnoses = create_list :diagnosis, 2
      {
        created_diagnoses: { count: 2, items: diagnoses },
        updated_diagnoses: { count: 2, items: diagnoses },
        completed_diagnoses: { count: 2, items: diagnoses },
        contacted_experts_count: 3
      }
    end

    it_behaves_like 'an email'

    it { expect(mail.from).to eq TerritoryUserMailer::SENDER }
  end
end
