require 'rails_helper'

RSpec.describe UserRight do
  describe 'associations' do
    it do
      is_expected.to belong_to :user
    end

    it do
      is_expected.to belong_to(:territorial_zone).optional
    end
  end

  context 'validations' do
    let(:user) { create(:user) }
    let(:antenne) { create(:antenne) }

    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:category)
      end
    end

    describe 'is not valid with duplicate user, category, and antenne' do
      let!(:user_right) { create :user_right, user: user, category: :manager, antenne: antenne }
      let(:duplicate_user_right) { build :user_right, user: user, category: :manager, antenne: antenne }

      it do
        expect(duplicate_user_right).not_to be_valid
        expect(duplicate_user_right.errors[:user_id]).to include(I18n.t('errors.messages.taken'))
      end
    end

    describe 'manager_has_managed_antennes' do
      let(:user) { create :user }
      let(:user_right) { build :user_right, user: user, category: :manager }

      it do
        expect(user_right).not_to be_valid
        expect(user_right.errors[:rightable_element_id]).to include(I18n.t('errors.manager_without_managed_antennes'))
      end
    end

    describe 'cooperation_manager_has_managed_cooperation' do
      let(:user) { create :user }

      context 'without cooperation' do
        let(:user_right) { build :user_right, user: user, category: :cooperation_manager }

        it do
          expect(user_right).not_to be_valid
          expect(user_right.errors[:rightable_element_id]).to include(I18n.t('errors.cooperation_manager_without_managed_cooperation'))
        end
      end

      context 'with cooperation' do
        let(:user_right) { build :user_right, user: user, category: :cooperation_manager, rightable_element: create(:cooperation) }

        it do
          expect(user_right).to be_valid
        end
      end
    end

    describe 'be_admin_to_be_referent' do
      let!(:national_referent) { build :user_right, user: user, category: :national_referent }
      let!(:main_referent) { build :user_right, user: user, category: :main_referent }

      context 'normal user can’t be referent' do
        it do
          expect(national_referent).not_to be_valid
          expect(main_referent).not_to be_valid
          expect(national_referent.errors[:category]).to include(I18n.t('.errors.admin_for_referents'))
          expect(main_referent.errors[:category]).to include(I18n.t('.errors.admin_for_referents'))
        end
      end

      context 'admin user can be referent' do
        let(:user) { create :user, :admin }

        it do
          expect(national_referent).to be_valid
          expect(main_referent).to be_valid
        end
      end
    end

    describe 'only_one_user_by_referent' do
      let(:user) { create :user, :admin }
      let!(:national_referent) { create :user_right, user: user, category: :national_referent }
      let!(:main_referent) { create :user_right, user: user, category: :main_referent }
      let(:another_national_referent) { build :user_right, user: user, category: :national_referent }
      let(:another_main_referent) { build :user_right, user: user, category: :national_referent }

      it 'expect not to be valid' do
        expect(another_national_referent).not_to be_valid
        expect(another_main_referent).not_to be_valid
        expect(another_national_referent.errors[:category]).to include(I18n.t('.errors.one_user_for_referents'))
        expect(another_main_referent.errors[:category]).to include(I18n.t('.errors.one_user_for_referents'))
      end
    end

    describe 'territorial_referent_has_managed_region' do
      let(:user) { create :user }

      context 'without region' do
        let(:user_right) { build :user_right, user: user, category: :territorial_referent }

        it do
          expect(user_right).not_to be_valid
          expect(user_right.errors[:rightable_element_id]).to include(I18n.t('errors.territorial_referent_without_managed_region'))
        end
      end

      context 'with wrong zone type' do
        let(:territorial_zone) { create :territorial_zone, :commune }
        let(:user_right) { build :user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone }

        it do
          expect(user_right).not_to be_valid
          expect(user_right.errors[:rightable_element_id]).to include(I18n.t('errors.territorial_referent_without_managed_region'))
        end
      end

      context 'with region' do
        let(:territorial_zone) { create :territorial_zone, :region }
        let(:user_right) { build :user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone }

        it do
          expect(user_right).to be_valid
        end
      end

      context 'only one territorial_referent per region' do
        let(:territorial_zone) { create :territorial_zone, :region }
        let!(:existing_user_right) { create :user_right, user: create(:user), category: :territorial_referent, rightable_element: territorial_zone }
        let(:duplicate_user_right) { build :user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone }

        it 'does not allow duplicate territorial_referent for same region' do
          expect(duplicate_user_right).not_to be_valid
          expect(duplicate_user_right.errors[:rightable_element_id]).to include(I18n.t('errors.one_territorial_referent_per_region'))
        end
      end

      context 'allows territorial_referent for different regions' do
        let(:territorial_zone_1) { create :territorial_zone, :region, code: '11' }
        let(:territorial_zone_2) { create :territorial_zone, :region, code: '84' }
        let!(:user_right_1) { create :user_right, user: create(:user), category: :territorial_referent, rightable_element: territorial_zone_1 }
        let(:user_right_2) { build :user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone_2 }

        it 'allows territorial_referent for different regions' do
          expect(user_right_2).to be_valid
        end
      end
    end
  end

  describe 'FOR_ADMIN constant' do
    it 'includes territorial_referent' do
      expect(described_class::FOR_ADMIN).to include(:territorial_referent)
    end
  end
end
