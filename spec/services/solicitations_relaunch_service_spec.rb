# frozen_string_literal: true

require 'rails_helper'
describe SolicitationsRelaunchService do
  # Solicitation non complétée suivi d'une solicitation complété  ko
  let!(:solicitation1) { create :solicitation, email: 'edith@piaf.fr', status: :step_company, created_at: 1.day.ago }
  let!(:solicitation1_bis) { create :solicitation, email: 'edith@piaf.fr', status: :in_progress, created_at: 1.day.ago }
  # Solicitation non complété étape entreprise                    ok
  let!(:solicitation2) { create :solicitation, email: 'alain@chabat.fr', status: :step_company, created_at: 1.day.ago }
  # Solicitation non complété étape description                   ok
  let!(:solicitation3) { create :solicitation, email: 'ada@lovelace.uk', status: :step_description, created_at: 1.day.ago }
  # Solicitation complété                                         ko
  let!(:solicitation4) { create :solicitation, email: 'romain@de-la-haye.fr', status: :in_progress, created_at: 1.day.ago }
  # Solicitation non complété qui date de plus d'un jour          ko
  let!(:solicitation5) { create :solicitation, email: 'dhh@rails.dk', status: :step_company, created_at: 2.days.ago }
  let(:solicitations_to_relaunch) { [solicitation2, solicitation3] }

  describe '#find_not_completed_solicitations' do
    subject { described_class.find_not_completed_solicitations }

    it 'find not completed solicitations' do
      is_expected.to match_array(solicitations_to_relaunch)
    end
  end

  describe '#send_emails' do
    before { described_class.send_emails(solicitations_to_relaunch) }

    it 'send emails to solicitations not completed' do
      expect(ActionMailer::Base.deliveries.count).to eq 2
    end
  end
end
