require 'rails_helper'

RSpec.describe SharedSatisfactionPolicy, type: :policy do
  subject { described_class }

  permissions :show_navbar? do
    let(:user) { create :user, antenne: create(:antenne, institution: create(:institution)) }

    context "grants access if user is manager" do
      before { user.user_rights.create(category: :manager, rightable_element: user.antenne) }

      it { is_expected.to permit(user) }
    end

    context "grants access if user is simple conseiller" do
      before { user.experts << create(:expert, antenne: user.antenne) }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is admin" do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user) }
    end

    context "denies access if user only cooperation manager" do
      let(:user) { create :user, :cooperation_manager }

      it { is_expected.not_to permit(user) }
    end
  end
end
