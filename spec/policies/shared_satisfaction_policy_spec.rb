require 'rails_helper'

RSpec.describe SharedSatisfactionPolicy, type: :policy do
  subject { described_class }

  permissions :show_navbar? do
    let(:user) { create :user, antenne: create(:antenne, institution: create(:institution)) }

    context "grants access if user is from an expert provider institution" do
      before { user.institution.categories << create(:category, label: 'expert_provider') }

      it { is_expected.to permit(user) }
    end

    context "denies access if user is NOT from an expert provider institution" do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user) }
    end
  end
end
