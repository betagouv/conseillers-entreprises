require 'rails_helper'
require 'mailers/shared_examples_for_an_email'

describe SolicitationMailer do
  describe '#send_generic_email' do
    let(:solicitation) { create :solicitation }

    %i[
      no_expert moderation creation intermediary
      sie_tva_and_others sie_sip_declare_and_pay formalites_asso_agri_sci tns_training no_expert_agri
      carsat retirement_liberal_professions employee_labor_law recruitment_foreign_worker
      administrations_collectivites siret mediateurs kbis_extract
    ].each do |email_type|
      context "for #{email_type}" do
        before { create :solicitation_mail_template, email_type: email_type.to_s }

        subject(:mail) { described_class.send_email(solicitation, email_type).deliver_now }

        it_behaves_like 'an email'

        it { expect(mail.header[:to].value).to eq solicitation.email }
      end
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
        # Use Regex to ignore line breaks
        expect(mail.body.parts.first.body).to match(/#{second_landing_subject.description_explanation.split.join('\s*')}/)
        expect(mail.body.parts.first.body).to match(/#{second_landing_subject.title.split.join('\s*')}/)
      end
    end

    context 'when solicitation has no diagnosis' do
      it 'include initial subject title and description' do
        expect(mail.body.parts.first.body).to match(/#{initial_landing_subject.description_explanation.split.join('\s*')}/)
        expect(mail.body.parts.first.body).to match(/#{initial_landing_subject.title.split.join('\s*')}/)
      end
    end
  end
end
