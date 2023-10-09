require 'rails_helper'

RSpec.describe Manager::NeedsPolicy, type: :policy do

  subject { described_class }

  permissions :index? do
    context 'with normal user' do
      let(:user) { create :user, :invitation_accepted }

      it { is_expected.not_to permit(user, :index?) }
    end

    context 'with user manager' do
      let(:user) { create :user, :manager }

      it { is_expected.to permit(user, :index?) }
    end

    context 'with user admin' do
      let(:user) { create :user, :admin }

      it { is_expected.not_to permit(user, :index?) }
    end
  end
end
