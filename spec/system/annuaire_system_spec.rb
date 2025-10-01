require 'rails_helper'
require 'system_helper'

describe 'annuaire', :js do
  let(:user) { create :user, :admin }
  let(:region) { create :territory, :region, code_region: 1234 }
  let(:commune) { create :commune, regions: [region] }
  let!(:other_commune) { create :commune, regions: [region] }
  let!(:antenne) { create :antenne, territorial_level: :local, institution: institution, communes: [commune] }
  let(:institution) { create :institution, :expert_provider }
  let!(:another_institution) { create :institution, :expert_provider }

  before do
    login_as user, scope: :user
  end

  context 'annuaire/institutions' do
    it 'displays all institution' do
      visit 'annuaire/institutions'

      expect(page).to have_css 'h1', text: "Annuaire"
      expect(page).to have_css('.fr-table--c-annuaire', count: 1)
      expect(page).to have_css('tr', count: 3)

      select(region.name, from: 'institutions-region')
      click_on 'Chercher', id: 'search-institutions'
      expect(page).to have_css('tr', count: 2)
    end
  end

  context '/annuaire/institutions/:slug/domaines' do
    context 'without expert_subject' do
      it 'displays no institution subjects' do
        visit "annuaire/institutions/#{institution.slug}/domaines"

        expect(page).to have_css 'h1', text: institution.name
        expect(page).to have_css '.fr-alert', text: I18n.t('annuaire.subjects.index.no_subject')
        expect(page).to have_css('.fr-table--c-annuaire', count: 0)
      end
    end

    context 'with expert_subject' do
      let(:expert) { create :expert, antenne: antenne }
      let(:institution_subject) { create :institution_subject, institution: institution }
      let!(:expert_subject) { create :expert_subject, institution_subject: institution_subject, expert: expert }

      it 'displays all institution subjects' do
        visit "annuaire/institutions/#{institution.slug}/domaines"

        expect(page).to have_css 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
        expect(page).to have_css('tr', count: 2)
      end
    end
  end

  context '/annuaire/institutions/:slug/antennes' do
    context 'without antenne' do
      it 'displays no institution antennes' do
        visit "annuaire/institutions/#{another_institution.slug}/antennes"

        expect(page).to have_css 'h1', text: another_institution.name
        expect(page).to have_css('.fr-alert', text: I18n.t('annuaire.antennes.index.no_antenne'))
        expect(page).to have_css('.fr-table--c-annuaire', count: 0)
      end
    end

    context 'with antenne' do
      it 'displays all institution antennes' do
        visit "annuaire/institutions/#{institution.slug}/antennes"

        expect(page).to have_css 'h1', text: institution.name
        expect(page).to have_css('.fr-table--c-annuaire', count: 1)
        expect(page).to have_css('tr', count: 2)
      end
    end
  end

  context '/annuaire/institutions/:slug/antennes/:antenne_id/conseillers' do
    describe 'without user' do
      let!(:institution_subject) { create :institution_subject, institution: institution }

      before { AntenneCoverage::UpdateJob.perform_sync(antenne.id) }

      it 'displays no users' do
        visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"
        expect(page).to have_css 'h1', text: institution.name
        expect(page).to have_css('.fr-alert--info')
        expect(page).to have_text(I18n.t('annuaire.users.index.no_users'))
      end
    end

    context 'with user' do
      let!(:expert) { create :expert, antenne: antenne }
      let!(:user_1) { create :user, experts: [expert], antenne: antenne }

      describe 'one expert with institution_subject' do
        let!(:institution_subject) { create :institution_subject, institution: institution }
        let!(:expert_subject) { create :expert_subject, institution_subject: institution_subject, expert: expert }

        before { AntenneCoverage::UpdateJob.perform_sync(antenne.id) }

        it 'display users without warning' do
          visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"

          expect(page).to have_css 'h1', text: institution.name
          expect(page).to have_css('.fr-table--c-annuaire', count: 1)
          expect(page).to have_css('.td-header--user', count: 1)
          expect(page).to have_css('.success-table-cell', count: 1)
          expect(page).to have_button('L')
        end
      end

      describe 'many experts on institution_subject' do
        let!(:institution_subject) { create :institution_subject, institution: institution }
        let!(:expert_subject) { create :expert_subject, institution_subject: institution_subject, expert: expert }
        let!(:expert_subject_2) { create :expert_subject, institution_subject: institution_subject, expert: expert_2 }
        let!(:expert_2) { create :expert, antenne: antenne }
        let!(:user_2) { create :user, experts: [expert_2], antenne: antenne }
        let(:communes_1) { create :commune }
        let(:communes_2) { create :commune }
        let(:communes_3) { create :commune }

        before do
          antenne.communes = [communes_1, communes_2, communes_3]
        end

        # Sans zone spécifique
        context 'without specifics territories' do
          before do
            AntenneCoverage::UpdateJob.perform_sync(antenne.id)
            visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"
          end

          it 'display users with many experts warning' do
            expect(page).to have_css 'h1', text: institution.name
            expect(page).to have_css('.fr-table--c-annuaire', count: 1)
            expect(page).to have_css('.td-header--user', count: 2)
            expect(page).to have_css('.error-table-cell')
            expect(page).to have_button('L', title: "Plusieurs experts pour le même sujet - Voir le détail")
          end
        end

        # Avec zone spécifique et des communes manquantes
        context 'experts with specific zone and experts.communes != antenne.communes' do
          before do
            expert.communes = [communes_1]
            expert_2.communes = [communes_2]
            AntenneCoverage::UpdateJob.perform_sync(antenne.id)
            visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"
          end

          it 'display users with missing experts warning' do
            expect(page).to have_css('.error-table-cell')
            expect(page).to have_button('L', title: "Experts manquants dans certaines communes - Voir le détail")
          end
        end

        # Avec zone spécifique et toutes les communes
        context 'experts with specific zone and experts.communes == antennes.communes' do
          before do
            expert.communes = [communes_1]
            expert_2.communes = [communes_2, communes_3]
            AntenneCoverage::UpdateJob.perform_sync(antenne.id)
            visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"
          end

          it 'display users with no warning' do
            expect(page).to have_css('.success-table-cell', count: 1)
            expect(page).to have_button('L')
          end
        end

        # Avec zone spécifique et des communes en doublons
        context 'experts with specific zone and experts.communes > antennes.communes' do
          before do
            expert.communes = [communes_1, communes_3]
            expert_2.communes = [communes_2, communes_3]
            AntenneCoverage::UpdateJob.perform_sync(antenne.id)
            visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"
          end

          it 'display users with many experts warning' do
            expect(page).to have_css('.error-table-cell')
            expect(page).to have_button('L', title: "Plusieurs experts pour le même sujet - Voir le détail")
          end
        end

        # Avec un expert zone spécifique et une équipe sur l’antenne
        context 'experts with specific zone and expert without' do
          before do
            expert.communes = [communes_1]
            AntenneCoverage::UpdateJob.perform_sync(antenne.id)
            visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"
          end

          it 'display users with many experts warning' do
            expect(page).to have_css('.error-table-cell')
            expect(page).to have_button('L', title: "Plusieurs experts pour le même sujet - Voir le détail")
          end
        end
      end

      describe 'expert without institution_subject' do
        let!(:institution_subject) { create :institution_subject, institution: institution }
        let!(:antenne_user) { create :user, experts: [create(:expert, :with_expert_subjects)], antenne: antenne }

        before { AntenneCoverage::UpdateJob.perform_sync(antenne.id) }

        it 'display users with no expert warning' do
          visit "annuaire/institutions/#{institution.slug}/antennes/#{antenne.id}/conseillers"
          expect(page).to have_css 'h1', text: institution.name
          expect(page).to have_css('.fr-table--c-annuaire', count: 1)
          expect(page).to have_css('.td-header--user', count: 1)
          expect(page).to have_css('.error-table-cell')
          expect(page).to have_button('?', title: "Aucun expert - Voir le détail")
        end
      end
    end
  end
end
