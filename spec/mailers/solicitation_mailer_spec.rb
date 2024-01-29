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

  describe '#bad_quality' do
    let(:landing) { create :landing }
    let!(:initial_subject) { create :subject }
    let!(:initial_landing_theme) { create :landing_theme, landings: [landing] }
    let!(:initial_landing_subject) { create :landing_subject, subject: initial_subject, description_explanation: "initial description", landing_theme: initial_landing_theme }
    let!(:solicitation) { create :solicitation, landing_subject: initial_landing_subject, landing: landing }

    subject(:mail) { described_class.bad_quality(solicitation).deliver_now }

    context 'when need has been changed' do
      let!(:second_landing_theme) { create :landing_theme, landings: [landing] }
      let!(:second_landing_subject) { create :landing_subject, subject: second_subject, description_explanation: "second description", landing_theme: second_landing_theme }
      let!(:second_subject) { create :subject }
      let!(:need) { create :need_with_matches, solicitation: solicitation, subject: second_subject }

      it_behaves_like 'an email'

      it 'include new subject title and description' do
        expect(mail.body.parts.first.body).not_to include initial_landing_subject.description_explanation
        expect(mail.body.parts.first.body).not_to include initial_landing_subject.title
        expect(mail.body.parts.first.body).to include second_landing_subject.description_explanation
        expect(mail.body.parts.first.body).to include second_landing_subject.title
      end
    end

    context 'when solicitation has no diagnosis' do
      it 'include initial subject title and description' do
        expect(mail.body.parts.first.body).to include initial_landing_subject.description_explanation
        expect(mail.body.parts.first.body).to include initial_landing_subject.title
      end
    end
  end
end
