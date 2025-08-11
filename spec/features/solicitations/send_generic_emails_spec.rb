require 'rails_helper'

describe 'send generic emails' do
  let!(:solicitation) { create :solicitation, full_name: "Top Entreprise" }

  login_admin

  before { visit conseiller_solicitations_path }

  it 'have email button' do
    expect(page).to have_css('#generic-emails', count: 1)
  end
end
