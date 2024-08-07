require 'rails_helper'

describe 'Annuaire::Users' do
  login_admin

  before { create_home_landing }

  describe 'GET #index' do
    let(:institution_1) { create :institution }
    let(:subject_1) { create :subject }
    let!(:institution_subject) { create :institution_subject, institution: institution_1, subject: subject_1 }
    let!(:antenne_1) { create :antenne, communes: [commune_ouest], institution: institution_1 }
    let!(:user_1) { create :user, :invitation_accepted, antenne: antenne_1, experts: [expert_1] }
    let!(:expert_1) { create :expert, :with_expert_subjects, antenne: antenne_1 }
    let!(:expert_1_same_antenne) { create :expert, :with_expert_subjects, antenne: antenne_1 }
    let!(:antenne_2) { create :antenne, communes: [commune_est], institution: institution_1 }
    let!(:expert_2) { create :expert, :with_expert_subjects, antenne: antenne_2 }
    let!(:region_ouest) { create :territory, code_region: 1 }
    let!(:region_est) { create :territory, code_region: 2 }
    let!(:commune_ouest) { create :commune, regions: [region_ouest] }
    let!(:commune_est) { create :commune, regions: [region_est] }

    context 'with an institution params' do
      before { visit institution_users_path(institution_slug: institution_1.slug) }

      it 'return all users for the institution' do
        expect(page).to have_content(antenne_1.name)
        expect(page).to have_content(expert_1.full_name)
        expect(page).to have_content(expert_1_same_antenne.full_name)
        expect(page).to have_content(expert_2.full_name)
      end
    end

    context 'with a user params' do
      before { visit institution_users_path(institution_slug: institution_1.slug, advisor: user_1, antenne_id: antenne_1.id) }

      it 'return all users for the user antenne' do
        expect(page).to have_content(antenne_1.name)
        expect(page).to have_content(expert_1.full_name)
        expect(page).to have_content(user_1.full_name)
        expect(page).to have_content(expert_1_same_antenne.full_name)
      end
    end

    context 'with an antenne params' do
      before { visit institution_users_path(institution_slug: institution_1.slug, antenne_id: antenne_1.id) }

      it 'return all users for the antenne' do
        expect(page).to have_content(antenne_1.name)
        expect(page).to have_content(expert_1.full_name)
        expect(page).to have_content(expert_1_same_antenne.full_name)
      end
    end

    context 'with a manager without experts' do
      let!(:manager) { create :user, antenne: antenne_1 }

      before do
        manager.managed_antennes.push(antenne_1)
        visit institution_users_path(institution_slug: institution_1.slug)
      end

      it 'return all users for the antenne' do
        expect(page).to have_content(antenne_1.name)
        expect(page).to have_content(manager.full_name)
      end
    end
  end
end
