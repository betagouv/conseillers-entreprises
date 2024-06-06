# frozen_string_literal: true

require 'rails_helper'

describe 'send generic emails' do
  let!(:solicitation) { create :solicitation, full_name: "Top Entreprise" }

  login_admin

  before { visit conseiller_solicitations_path }

  it 'have email button' do
    expect(page).to have_css('#generic-emails', count: 1)
  end

  describe "send all emails in GENERIC_EMAILS_TYPES" do
    Solicitation::GENERIC_EMAILS_TYPES.each do |email_type|
      it "displays #{email_type}" do
        click_on I18n.t(email_type, scope: "solicitations.solicitation_actions.emails")
        expect(page.html).to include I18n.t('emails.sent')
      end
    end
  end
end
