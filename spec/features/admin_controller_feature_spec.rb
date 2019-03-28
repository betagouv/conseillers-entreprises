# frozen_string_literal: true

require 'rails_helper'

describe 'admin panel', type: :feature do
  login_user

  describe 'user access to panel' do
    context 'user is admin' do
      before do
        current_user.update is_admin: true
        visit '/admin'
      end

      it { expect(page.html).to include 'Tableau de bord' }
    end
  end

  describe 'user access to admin pages' do
    before do
      current_user.update is_admin: true
      visit '/admin'

      click_link 'Utilisateurs'
      click_link 'Créer Utilisateur'

      click_link 'Entreprises'
      click_link 'Créer Entreprise'

      click_link 'Contact'
      click_link 'Créer Contact'

      click_link 'Catégories'
      click_link 'Créer Catégorie'

      click_link 'Besoins'
      click_link 'Créer Besoin'

      click_link 'Compétence'
      click_link 'Créer Compétence'

      click_link 'Établissement'
      click_link 'Créer Établissement'

      click_link 'Institutions'
      click_link 'Créer Institution'

      click_link 'Référents'
      click_link 'Créer Référent'

      click_link 'Besoins identifiés'

      click_link 'Mises en relation'

      click_link 'Territoires'
      click_link 'Créer Territoire'

      click_link 'Communes'
      click_link 'Créer Commune'

      click_link current_user.full_name
    end

    it 'displays user name' do
      expect(page.html).to include current_user.full_name
    end
  end

  describe 'access to matches page when no diagnosis' do
    let(:match) { create :match }

    before do
      current_user.update is_admin: true
      visit '/admin'

      match.diagnosed_need.diagnosis.archive!

      click_link 'Mises en relation'
    end

    it('displays page content') { expect(page.html).to include 'Mises en relation' }
  end
end
