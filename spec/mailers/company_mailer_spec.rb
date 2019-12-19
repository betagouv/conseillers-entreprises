# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe CompanyMailer do
  describe '#confirmation_solicitation' do
    subject(:mail) { described_class.confirmation_solicitation(solicitation.email).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end

  describe '#taking_care_by_expert' do
    subject(:mail) { described_class.taking_care_by_expert(a_match).deliver_now }

    let(:solicitation) { create :solicitation }
    let(:a_match) { create :match }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end

  describe '#taking_care_by_support' do
    subject(:mail) { described_class.taking_care_by_support(a_match).deliver_now }

    let(:solicitation) { create :solicitation }
    let(:a_match) { create :match }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER }
  end
end
