# frozen_string_literal: true

require 'rails_helper'

describe 'admin panel', type: :feature do
  login_user

  before do
    visit '/admin'
    expect(page).not_to have_content 'Tableau de bord'

    current_user.update is_admin: true

    visit '/admin'
    expect(page).to have_content 'Tableau de bord'

    click_link 'Utilisateurs'
    click_link 'Créer Utilisateur'

    click_link 'Visites'
    click_link 'Créer Visite'

    click_link 'Institutions'
    click_link 'Créer Institution'

    click_link 'Contact'
    click_link 'Créer Contact'

    click_link 'Catégories'
    click_link 'Créer Catégorie'

    click_link 'Questions'
    click_link 'Créer Question'

    click_link 'Aides'
    click_link 'Créer Aide'

    click_link current_user.full_name
  end

  it 'displays user name' do
    expect(page).to have_content current_user.full_name
  end
end
