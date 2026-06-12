require 'rails_helper'

RSpec.describe Emails::SolicitationsController do
  login_admin
  render_views

  describe '#send_generic_email' do
    let!(:solicitation) { create :solicitation, full_name: "Top Entreprise" }

    %i[
      bad_quality no_expert moderation creation intermediary
      sie_tva_and_others sie_sip_declare_and_pay formalites_asso_agri_sci tns_training no_expert_agri
      carsat retirement_liberal_professions employee_labor_law recruitment_foreign_worker
      administrations_collectivites siret mediateurs kbis_extract
    ].each do |email_type|
      it "displays #{email_type}" do
        create(:solicitation_mail_template, email_type: email_type.to_s) unless email_type == :bad_quality
        post :send_generic_email, params: { id: solicitation.id, email_type: email_type }, as: :turbo_stream
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include(I18n.t('emails.sent'))
      end
    end
  end
end
