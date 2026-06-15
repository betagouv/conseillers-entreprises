require 'rails_helper'

RSpec.describe Emails::SolicitationsController do
  login_admin
  render_views

  describe '#send_generic_email' do
    let!(:solicitation) { create :solicitation, full_name: "Top Entreprise" }

    # Dynamic types are driven by the templates stored in the database.
    # `bad_quality` is the special built-in type that has no template.
    let!(:templates) do
      %w[no_expert moderation creation intermediary].map do |email_type|
        create(:solicitation_mail_template, email_type: email_type)
      end
    end

    it 'sends each available email type' do
      solicitation.available_email_types.each do |email_type|
        post :send_generic_email, params: { id: solicitation.id, email_type: email_type }, as: :turbo_stream
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to(include(I18n.t('emails.sent')), "expected #{email_type} email to be sent")
      end
    end

    it 'rejects an unknown email type' do
      post :send_generic_email, params: { id: solicitation.id, email_type: :nonexistent }, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('emails.not_sent'))
    end
  end
end
