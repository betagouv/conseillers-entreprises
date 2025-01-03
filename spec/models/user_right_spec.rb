require 'rails_helper'

RSpec.describe UserRight do
  describe 'associations' do
    it do
      is_expected.to belong_to :user
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
        duplicate_user_right.valid?
        expect(duplicate_user_right.errors[:user_id]).to include(I18n.t('errors.messages.taken'))
        expect(duplicate_user_right).not_to be_valid
      end
    end

    describe 'manager_has_managed_antennes' do
      let(:user) { create :user }
      let(:user_right) { build :user_right, user: user, category: :manager }

      it do
        user_right.valid?
        expect(user_right.errors[:rightable_element_id]).to include(I18n.t('errors.manager_without_managed_antennes'))
        expect(user_right).not_to be_valid
      end
    end

    describe 'be_admin_to_be_referent' do
      let!(:national_referent) { build :user_right, user: user, category: :national_referent }
      let!(:main_referent) { build :user_right, user: user, category: :main_referent }

      context 'normal user can’t be referent' do
        it do
          national_referent.valid?
          main_referent.valid?
          expect(national_referent.errors[:category]).to include(I18n.t('.errors.admin_for_referents'))
          expect(main_referent.errors[:category]).to include(I18n.t('.errors.admin_for_referents'))
          expect(national_referent).not_to be_valid
          expect(main_referent).not_to be_valid
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
        another_national_referent.valid?
        another_main_referent.valid?
        expect(another_national_referent.errors[:category]).to include(I18n.t('.errors.one_user_for_referents'))
        expect(another_main_referent.errors[:category]).to include(I18n.t('.errors.one_user_for_referents'))
        expect(another_national_referent).not_to be_valid
        expect(another_main_referent).not_to be_valid
      end
    end
  end
end
