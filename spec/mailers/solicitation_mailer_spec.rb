# frozen_string_literal: true

require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe SolicitationMailer do
  describe '#send_generic_email' do
    let(:solicitation) { create :solicitation }

    Solicitation::GENERIC_EMAILS_TYPES.each do |email_type|
      subject(:mail) { described_class.send(email_type, solicitation).deliver_now }

      it_behaves_like 'an email'

      it { expect(mail.header[:to].value).to eq solicitation.email }
    end
  end
end
