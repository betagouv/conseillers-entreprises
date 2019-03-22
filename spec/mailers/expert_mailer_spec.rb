# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe ExpertMailer do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe '#notify_company_needs' do
    subject(:mail) { described_class.notify_company_needs(expert, diagnosis).deliver_now }

    let(:expert) { create :expert }
    let(:assistances) { create_list :assistance, 2 }
    let(:user) { create :user }
    let(:question) { create :question }
    let(:diagnosis) { create :diagnosis, advisor: user, visitee: create(:contact, :with_email) }
    let(:questions_with_needs_description) { [{ question: question, need_description: 'Help this company' }] }

    let(:params_hash) do
      {
        visit_date: diagnosis.happened_on,
        diagnosis_id: diagnosis.id,
        company_name: diagnosis.company.name,
        company_contact: diagnosis.visitee,
        questions_with_needs_description: questions_with_needs_description,
        advisor: user
      }
    end

    it_behaves_like 'an email'

    it { expect(mail.from).to eq ExpertMailer::SENDER }
  end

  describe '#remind_involvement' do
    subject(:mail) do
      described_class.remind_involvement(expert,
        [match_taken_not_done],
        [match_quo_not_taken]).deliver_now
    end

    let(:expert) { create :expert }
    let(:match_taken_not_done) { create :match }
    let(:match_quo_not_taken) { create :match }

    it_behaves_like 'an email'

    it { expect(mail.from).to eq ExpertMailer::SENDER }
  end
end
