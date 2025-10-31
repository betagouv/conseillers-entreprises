require 'rails_helper'

RSpec.describe Emails::SolicitationsController do
  login_admin
  render_views

  describe '#send_generic_email' do
    let!(:solicitation) { create :solicitation, full_name: "Top Entreprise" }

    Solicitation::GENERIC_EMAILS_TYPES.flatten.each do |email_type|
      it "displays #{email_type}" do
        # click_on I18n.t(email_type, scope: "solicitations.solicitation_actions.emails")
        # expect(page.html).to have_css('turbo-frame', text: I18n.t('emails.sent'))
        post :send_generic_email, params: { id: solicitation.id, email_type: email_type }, as: :turbo_stream
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include(I18n.t('emails.sent'))
      end
    end
  end
end
