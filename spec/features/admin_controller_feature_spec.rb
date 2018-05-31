# frozen_string_literal: true

require 'rails_helper'

describe 'admin panel', type: :feature do
  login_user

  describe 'user access to panel' do
    context 'user is not admin' do
      before { visit '/admin' }

      it { expect(page).not_to have_content 'Tableau de bord' }
    end

    context 'user is admin' do
      before do
        current_user.update is_admin: true
        visit '/admin'
      end

      it { expect(page).to have_content 'Tableau de bord' }
    end
  end

  describe 'user access to admin pages' do
    before do
      current_user.update is_admin: true
      visit '/admin'

      click_link 'Utilisateurs'
      click_link 'Créer Utilisateur'

      click_link 'Visites'

      click_link 'Entreprises'
      click_link 'Créer Entreprise'

      click_link 'Contact'
      click_link 'Créer Contact'

      click_link 'Catégories'
      click_link 'Créer Catégorie'

      click_link 'Besoins'
      click_link 'Créer Besoin'

      click_link 'Champs de compétence'
      click_link 'Créer Champ de compétence'

      click_link 'Établissement'
      click_link 'Créer Établissement'

      click_link 'Institutions'
      click_link 'Créer Institution'

      click_link 'Référents'
      click_link 'Créer Référent'

      click_link 'Besoins analysés'

      click_link 'Référents contactés'

      click_link 'Territoires'
      click_link 'Créer Territoire'

      click_link 'Villes d’un territoire'
      click_link 'Créer Ville d’un territoire'

      click_link current_user.full_name
    end

    it 'displays user name' do
      expect(page).to have_content current_user.full_name
    end
  end

  describe 'access to selected_assistances_experts page when no diagnosis' do
    let(:selected_assistance_expert) { create :selected_assistance_expert }

    before do
      current_user.update is_admin: true
      visit '/admin'

      selected_assistance_expert.diagnosed_need.diagnosis.archive!

      click_link 'Référents contactés'
    end

    it('displays page content') { expect(page).to have_content 'Référents contactés' }
  end
end
