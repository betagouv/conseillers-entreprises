# frozen_string_literal: true

require 'rails_helper'

describe 'admin panel' do
  login_user

  describe 'user access to panel' do
    context 'user is admin' do
      before do
        current_user.user_rights.create(category: 'admin')
        visit '/admin'
      end

      it { expect(page.html).to include 'Sollicitations' }
    end
  end

  describe 'user access to admin pages' do
    before do
      current_user.user_rights.create(category: 'admin')
      # Dummy data, so as to thoroughly check views
      create_base_dummy_data
      visit '/admin'

      click_link 'Utilisateurs'
      click_link 'Créer Utilisateur'

      click_link 'Entreprises'
      click_link 'Créer Entreprise'

      click_link 'Contact'
      click_link 'Créer Contact'

      click_link 'Experts'
      click_link 'Créer Expert'
      visit "/admin/experts/#{Expert.first.id}"
      click_link 'Modifier Expert'
      click_button 'Modifier ce(tte) Expert'

      click_link 'Antennes'
      click_link 'Créer Antenne'

      click_link 'Institutions'
      click_link 'Créer Institution'

      click_link 'Logos'
      click_link 'Créer Logo'

      click_link 'Territoires'
      click_link 'Créer Territoire'

      click_link 'Communes'
      click_link 'Créer Commune'

      click_link 'Thématiques'
      click_link 'Créer Thématique'

      click_link 'Sujets'
      click_link 'Créer Sujet'

      click_link 'Landings'
      click_link 'Créer Landing'

      click_link 'Thématiques de landing'
      click_link 'Créer Thématique de landing'

      click_link 'Sollicitations'
      visit "/admin/solicitations/#{Solicitation.first.id}"
      click_link 'Modifier Sollicitation'
      click_button 'Modifier ce(tte) Sollicitation'

      click_link 'Analyses'
      click_link 'Créer Analyse'

      click_link 'Besoins'
      click_link 'Créer Besoin'

      click_link 'Mises en relation'
      click_link 'Créer Mise en relation'

      click_link 'Commentaires'
      click_link 'Créer Commentaire'

      click_link 'Entreprises'
      click_link 'Créer Entreprise'

      click_link 'Établissements'
      click_link 'Créer Établissement'

      click_link 'Contacts'
      click_link 'Créer Contact'

      click_link 'Satisfactions'
      click_link 'Créer Satisfaction'

      click_link 'Email Retentions'
      click_link 'Créer Email Retention'

      click_link current_user.full_name
    end

    it 'displays user name' do
      expect(page.html).to include current_user.full_name
    end
  end

  describe 'access to matches page when no diagnosis' do
    let(:match) { create :match }

    before do
      current_user.user_rights.create(category: 'admin')
      visit '/admin'

      click_link 'Mises en relation'
    end

    it('displays page content') { expect(page.html).to include 'Mises en relation' }
  end
end
