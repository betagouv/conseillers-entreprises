# frozen_string_literal: true

require 'rails_helper'

describe 'send generic emails', type: :feature do
  let!(:solicitation) { create :solicitation, full_name: "Top Entreprise" }

  login_admin

  before { visit solicitations_path }

  it 'have email button' do
    expect(page).to have_css('#generic-emails', count: 1)
  end

  it 'send bad_quality_difficulties email' do
    expect(page.html).to include "Top Entreprise"
    within("#solicitation-#{solicitation.id}-badges") do
      expect(page).not_to have_content I18n.t('solicitations.solicitation_actions.emails.bad_quality_difficulties')
    end
    click_link I18n.t('solicitations.solicitation_actions.emails.bad_quality_difficulties')
    expect(page.html).to include I18n.t('emails.sent')
    expect(page.html).not_to include "Top Entreprise"

    visit canceled_solicitations_path
    expect(page.html).to include "Top Entreprise"
    within("#solicitation-#{solicitation.id}-badges") do
      expect(page).to have_content I18n.t('solicitations.solicitation_actions.emails.bad_quality_difficulties')
    end
  end

  it 'send bad_quality email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.bad_quality')
    expect(page.html).to include I18n.t('emails.sent')
  end

  it 'send out_of_region email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.out_of_region')
    expect(page.html).to include I18n.t('emails.sent')
  end

  it 'send employee_labor_law email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.employee_labor_law')
    expect(page.html).to include I18n.t('emails.sent')
  end

  it 'send particular_retirement email' do
    click_link I18n.t('solicitations.solicitation_actions.emails.particular_retirement')
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
