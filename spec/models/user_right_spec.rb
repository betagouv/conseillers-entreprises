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

    describe 'be_admin_to_have_rights_for_admins' do
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

      context 'with singleton categories' do
        it 'prevents duplicate national_referent' do
          create(:user_right, user: create(:user, :admin), category: :national_referent)
          duplicate_referent = build(:user_right, user: user, category: :national_referent)

          expect(duplicate_referent).not_to be_valid
          expect(duplicate_referent.errors[:category]).to include(I18n.t('.errors.one_user_for_referents'))
        end

        it 'prevents duplicate main_referent' do
          create(:user_right, user: create(:user, :admin), category: :main_referent)
          duplicate_referent = build(:user_right, user: user, category: :main_referent)

          expect(duplicate_referent).not_to be_valid
          expect(duplicate_referent.errors[:category]).to include(I18n.t('.errors.one_user_for_referents'))
        end

        it 'prevents duplicate cooperations_referent' do
          create(:user_right, user: create(:user, :admin), category: :cooperations_referent)
          duplicate_referent = build(:user_right, user: user, category: :cooperations_referent)

          expect(duplicate_referent).not_to be_valid
          expect(duplicate_referent.errors[:category]).to include(I18n.t('.errors.one_user_for_referents'))
        end
      end

      context 'with non-singleton categories' do
        it 'allows multiple managers' do
          create(:user_right, user: create(:user), category: :manager, rightable_element: create(:antenne))
          another_manager = build(:user_right, user: user, category: :manager, rightable_element: create(:antenne))

          expect(another_manager).to be_valid
        end
      end
    end

    describe 'territorial_referent_has_managed_region' do
      let(:user) { create :user, :admin }

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
        let(:territorial_zone_1) { create :territorial_zone, :region, code: '11' }
        let(:territorial_zone_2) { create :territorial_zone, :region, code: '11' }
        let!(:user_right_1) { create :user_right, user: create(:user, :admin), category: :territorial_referent, rightable_element: territorial_zone_1 }
        let(:user_right_2) { build :user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone_2 }

        it 'does not allow duplicate territorial_referent for same region' do
          expect(user_right_2).not_to be_valid
          expect(user_right_2.errors[:rightable_element_id]).to include(I18n.t('errors.one_territorial_referent_per_region'))
        end
      end

      context 'allows territorial_referent for different regions' do
        let(:territorial_zone_1) { create :territorial_zone, :region, code: '11' }
        let(:territorial_zone_2) { create :territorial_zone, :region, code: '84' }
        let!(:user_right_1) { create :user_right, user: create(:user, :admin), category: :territorial_referent, rightable_element: territorial_zone_1 }
        let(:user_right_2) { build :user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone_2 }

        it 'allows territorial_referent for different regions' do
          expect(user_right_2).to be_valid
        end
      end

      context 'editing existing territorial_referent' do
        let(:territorial_zone) { create :territorial_zone, :region }
        let!(:existing_user_right) { create :user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone }

        it 'allows updating the same record without validation error' do
          existing_user_right.reload
          existing_user_right.updated_at = Time.current
          expect(existing_user_right).to be_valid
        end
      end
    end
  end

  describe 'Constants' do
    describe 'ADMIN_ONLY_CATEGORIES' do
      it 'includes all admin-only categories' do
        expect(described_class::ADMIN_ONLY_CATEGORIES).to contain_exactly(
          :admin, :national_referent, :main_referent, :cooperations_referent, :territorial_referent
        )
      end
    end

    describe 'SINGLETON_CATEGORIES' do
      it 'includes categories that should have only one user' do
        expect(described_class::SINGLETON_CATEGORIES).to contain_exactly(
          :national_referent, :main_referent, :cooperations_referent
        )
      end
    end
  end

  describe 'Utility methods' do
    let(:user) { create(:user, :admin) }
    let(:territorial_zone) { create(:territorial_zone, :region) }
    let(:user_right) { build(:user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone) }

    describe '#valid_territorial_zone_region?' do
      context 'with valid region zone' do
        it 'returns true' do
          expect(user_right.send(:valid_territorial_zone_region?)).to be true
        end
      end

      context 'with non-region zone' do
        let(:territorial_zone) { create(:territorial_zone, :commune) }

        it 'returns false' do
          expect(user_right.send(:valid_territorial_zone_region?)).to be false
        end
      end

      context 'with non-territorial zone' do
        let(:user_right) { build(:user_right, user: user, category: :manager, rightable_element: create(:antenne)) }

        it 'returns false' do
          expect(user_right.send(:valid_territorial_zone_region?)).to be false
        end
      end
    end

    describe '#existing_singleton_right_exists?' do
      context 'when singleton right already exists' do
        before { create(:user_right, user: create(:user, :admin), category: :national_referent) }

        let(:user_right) { build(:user_right, user: user, category: :national_referent) }

        it 'returns true' do
          expect(user_right.send(:existing_singleton_right_exists?)).to be true
        end
      end

      context 'when no singleton right exists' do
        let(:user_right) { build(:user_right, user: user, category: :national_referent) }

        it 'returns false' do
          expect(user_right.send(:existing_singleton_right_exists?)).to be false
        end
      end
    end

    describe '#existing_territorial_referent_for_region?' do
      context 'when territorial referent exists for same region' do
        before do
          other_zone = create(:territorial_zone, :region, code: territorial_zone.code)
          create(:user_right, user: create(:user, :admin), category: :territorial_referent, rightable_element: other_zone)
        end

        it 'returns true' do
          expect(user_right.send(:existing_territorial_referent_for_region?)).to be true
        end
      end

      context 'when no territorial referent exists for region' do
        it 'returns false' do
          expect(user_right.send(:existing_territorial_referent_for_region?)).to be false
        end
      end

      context 'when territorial referent exists for different region' do
        before do
          other_zone = create(:territorial_zone, :region, code: '84')
          create(:user_right, user: create(:user, :admin), category: :territorial_referent, rightable_element: other_zone)
        end

        it 'returns false' do
          expect(user_right.send(:existing_territorial_referent_for_region?)).to be false
        end
      end

      context 'when editing existing territorial referent' do
        let!(:existing_user_right) { create(:user_right, user: user, category: :territorial_referent, rightable_element: territorial_zone) }

        it 'returns false for the same record being edited' do
          existing_user_right.reload
          expect(existing_user_right.send(:existing_territorial_referent_for_region?)).to be false
        end
      end
    end
  end
end
