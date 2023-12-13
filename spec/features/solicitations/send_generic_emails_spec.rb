# frozen_string_literal: true

require 'rails_helper'

describe 'send generic emails' do
  let!(:solicitation) { create :solicitation, full_name: "Top Entreprise" }

  login_admin

  before { visit conseiller_solicitations_path }

  it 'have email button' do
    expect(page).to have_css('#generic-emails', count: 1)
  end

  it 'send bad_quality email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.bad_quality')
    expect(page.html).to include I18n.t('emails.sent')
  end

  it 'send employee_labor_law email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.employee_labor_law')
    expect(page.html).to include I18n.t('emails.sent')
  end

  it 'send creation email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.creation')
    expect(page.html).to include I18n.t('emails.sent')
  end

  it 'send siret email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.siret')
    expect(page.html).to include I18n.t('emails.sent')
  end

  it 'send moderation email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.moderation')
    expect(page.html).to include I18n.t('emails.sent')
  end
end
