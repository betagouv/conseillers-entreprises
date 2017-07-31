# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe ExpertMailer do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe '#notify_company_needs' do
    subject(:mail) { described_class.notify_company_needs(expert, params_hash).deliver_now }

    let(:expert) { create :expert }
    let(:assistances) { create_list :assistance, 2 }
    let(:user) { create :user }
    let(:visit) { create :visit, :with_visitee, advisor: user }

    let(:params_hash) do
      {
        visit_date: visit.happened_at_localized,
        company_name: visit.company_name,
        company_contact: visit.visitee,
        assistances: assistances,
        advisor: user,
        expert_institution: expert.institution.name
      }
    end

    it_behaves_like 'an email'

    it { expect(mail.from).to eq ExpertMailer::SENDER }
  end
end
