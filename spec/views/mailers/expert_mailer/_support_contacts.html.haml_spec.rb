require 'rails_helper'

RSpec.describe 'mailers/expert_mailer/_support_contacts.html.haml' do
  let!(:national_antenne) { national_manager.antenne }

  # if defined?(user) && user.is_manager? && antenne.national?
  # Si c'est un responsable d'antenne national
  let(:national_manager) { create(:user, :national_manager) }
  let!(:national_referent) { create(:user, :national_referent) }

  # elsif antenne.support_user.present?
  # Si c'est un utilisateur dans une antenne avec un referent support
  let(:commune) { create(:commune, regions: [region]) }
  let(:region) { create(:territory, :region, support_contact: support_user) }
  let!(:support_user) { create(:user) }
  let!(:antenne_with_support) { create :antenne, communes: [commune] }

  # else
  # Si il n'y a pas de referent support ou que c'est une antenne national
  let!(:another_support_user) { create(:user) }
  let!(:another_region) { create(:territory, :region, support_contact: another_support_user) }
  let!(:another_commune) { create(:commune, regions: [another_region]) }
  let!(:antenne_without_support) { create :antenne }

  context 'when user is a manager and antenne is national' do
    it 'renders national referent contacts' do

      render 'mailers/expert_mailer/support_contacts', user: national_manager, antenne: national_antenne

      expect(rendered).not_to include(support_user.full_name)
      expect(rendered).not_to include(support_user.phone_number)
      expect(rendered).not_to include(support_user.email)
      expect(rendered).not_to include(support_user.job)

      expect(rendered).not_to include(another_support_user.full_name)
      expect(rendered).not_to include(another_support_user.phone_number)
      expect(rendered).not_to include(another_support_user.email)
      expect(rendered).not_to include(another_support_user.job)

      # On affiche les informations du referent national
      expect(rendered).to include(national_referent.full_name)
      expect(rendered).to include(national_referent.phone_number)
      expect(rendered).to include(national_referent.email)
      expect(rendered).to include(national_referent.job)
    end
  end

  context 'when antenne has a support user' do
    it 'renders support contact' do
      render 'mailers/expert_mailer/support_contacts', antenne: antenne_with_support

      # On affiche les informations du referent support de la région
      expect(rendered).to include(support_user.full_name)
      expect(rendered).to include(support_user.phone_number)
      expect(rendered).to include(support_user.email)
      expect(rendered).not_to include(support_user.job)

      expect(rendered).not_to include(another_support_user.full_name)
      expect(rendered).not_to include(another_support_user.phone_number)
      expect(rendered).not_to include(another_support_user.email)
      expect(rendered).not_to include(another_support_user.job)

      expect(rendered).not_to include(national_manager.full_name)
      expect(rendered).not_to include(national_manager.phone_number)
      expect(rendered).not_to include(national_manager.email)
      expect(rendered).not_to include(national_manager.job)
    end
  end

  context 'when antenne does not have a support user' do
    it 'renders territory contacts' do
      render 'mailers/expert_mailer/support_contacts', antenne: antenne_without_support

      # On affiche les informations du referent support de toutes les régions
      expect(rendered).to include(support_user.full_name)
      expect(rendered).to include(support_user.phone_number)
      expect(rendered).to include(support_user.email)
      expect(rendered).not_to include(support_user.job)

      expect(rendered).to include(another_support_user.full_name)
      expect(rendered).to include(another_support_user.phone_number)
      expect(rendered).to include(another_support_user.email)
      expect(rendered).not_to include(another_support_user.job)

      expect(rendered).not_to include(national_manager.full_name)
      expect(rendered).not_to include(national_manager.phone_number)
      expect(rendered).not_to include(national_manager.email)
      expect(rendered).not_to include(national_manager.job)
    end
  end
end
