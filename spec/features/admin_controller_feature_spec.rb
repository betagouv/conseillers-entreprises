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

      click_on 'Utilisateurs'
      click_on 'Créer Utilisateur'

      click_on 'Recherches'

      click_on 'Entreprises'
      click_on 'Créer Entreprise'

      click_on 'Contact'
      click_on 'Créer Contact'

      click_on 'Experts'
      click_on 'Créer Expert'
      visit "/admin/experts/#{Expert.first.id}"
      click_on 'Modifier Expert'
      click_on 'Modifier ce(tte) Expert'

      click_on 'Antennes'
      click_on 'Créer Antenne'

      click_on 'Institutions'
      click_on 'Créer Institution'

      click_on 'Logos'
      click_on 'Créer Logo'

      click_on 'Territoires'
      click_on 'Créer Territoire'

      click_on 'Communes'
      click_on 'Créer Commune'

      click_on 'Thématiques'
      click_on 'Créer Thématique'

      click_on 'Sujets'
      click_on 'Créer Sujet'

      click_on 'Landings'
      click_on 'Créer Landing'

      click_on 'Thématiques de landing'
      click_on 'Créer Thématique de landing'

      click_on 'Sollicitations'
      visit "/admin/solicitations/#{Solicitation.first.id}"
      click_on 'Modifier Sollicitation'
      click_on 'Modifier ce(tte) Sollicitation'

      click_on 'Analyses'
      click_on 'Créer Analyse'

      click_on 'Besoins'
      click_on 'Créer Besoin'

      click_on 'Mises en relation'
      click_on 'Créer Mise en relation'

      click_on 'Commentaires'
      click_on 'Créer Commentaire'

      click_on 'Entreprises'
      click_on 'Créer Entreprise'

      click_on 'Établissements'
      click_on 'Créer Établissement'

      click_on 'Contacts'
      click_on 'Créer Contact'

      click_on 'Satisfactions'
      click_on 'Créer Satisfaction'

      click_on 'Email Retentions'
      click_on 'Créer Email Retention'

      click_on current_user.full_name
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

      click_on 'Mises en relation'
    end

    it('displays page content') { expect(page.html).to include 'Mises en relation' }
  end
end
