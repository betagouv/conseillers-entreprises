require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe CompanyMailer do
  describe '#confirmation_solicitation' do
    subject(:mail) { described_class.confirmation_solicitation(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER.call }
  end

  describe '#notify_taking_care' do
    subject(:mail) { described_class.notify_taking_care(a_match).deliver_now }

    let(:solicitation) { create :solicitation }
    let(:a_match) { create :match }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER.call }
  end

  describe '#solicitation_relaunch_company' do
    subject(:mail) { described_class.solicitation_relaunch_company(solicitation).deliver_now }

    let(:solicitation) { create :solicitation }

    it_behaves_like 'an email'

    it { expect(mail.header[:from].value).to eq ExpertMailer::SENDER.call }
  end

  describe '#not_yet_taken_care' do
    subject(:mail) { described_class.not_yet_taken_care(solicitation).deliver_now }

    let!(:initial_subject) { create :subject, label: "Sujet initial" }
    let!(:initial_landing_subject) { create :landing_subject, subject: initial_subject, title: "Sujet initial" }
    let!(:solicitation) { create :solicitation, landing_subject: initial_landing_subject }
    let!(:need) { create :need_with_matches, solicitation: solicitation, subject: need_subject }

    context 'when need has not been requalified' do
      let(:need_subject) { initial_subject }

      it_behaves_like 'an email'

      it 'uses the original subject in the body' do
        expect(mail.body.parts.first.body).to match(/#{initial_subject.label.split.join('\s*')}/)
      end
    end

    context 'when need has been requalified with a different subject' do
      let(:need_subject) { create :subject, label: "Sujet requalifié" }
      let!(:need_landing_subject) { create :landing_subject, subject: need_subject, title: "Sujet requalifié" }

      it_behaves_like 'an email'

      it 'uses the requalified subject in the body, not the original one' do
        expect(mail.body.parts.first.body).to match(/#{need_landing_subject.title.split.join('\s*')}/)
        expect(mail.body.parts.first.body).not_to include initial_landing_subject.title
      end

      it 'shows the same subject in the mail subject line and in the body' do
        expect(mail.subject).to eq I18n.t('mailers.company_mailer.not_yet_taken_care.subject', subject: solicitation.final_subject_title)
        expect(mail.body.parts.first.body).to match(/#{solicitation.final_subject_title.split.join('\s*')}/)
      end
    end
  end
end
