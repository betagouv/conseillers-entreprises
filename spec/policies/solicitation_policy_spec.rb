require 'rails_helper'

RSpec.describe SolicitationPolicy, type: :policy do
  let(:no_user) { nil }
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:solicitation) { create :solicitation }

  subject { described_class }

  permissions :index? do
    context "grants access to admin" do
      it { is_expected.to permit(admin, Solicitation) }
    end

    context "denies access to no admin user" do
      it { is_expected.not_to permit(user, Solicitation) }
      it { is_expected.not_to permit(no_user, Solicitation) }
    end
  end

  permissions :show? do
    context "grants access to admin" do
      it { is_expected.to permit(admin, solicitation) }
    end

    context "denies access to no admin user" do
      it { is_expected.not_to permit(user, solicitation) }
      it { is_expected.not_to permit(no_user, solicitation) }
    end
  end

  permissions :create? do
     context "grants access to everyone" do
        it { is_expected.to permit(no_user, solicitation) }
        it { is_expected.to permit(user, solicitation) }
        it { is_expected.to permit(admin, solicitation) }
      end
   end

  permissions :update? do
     context "grants access to admin" do
       it { is_expected.to permit(admin, solicitation) }
     end

     context "denies access to no admin user" do
       it { is_expected.not_to permit(user, solicitation) }
       it { is_expected.not_to permit(no_user, solicitation) }
     end
   end

  permissions :destroy? do
     context "grants access to admin" do
       it { is_expected.to permit(admin, solicitation) }
     end

     context "denies access to no admin user" do
       it { is_expected.not_to permit(user, solicitation) }
       it { is_expected.not_to permit(no_user, solicitation) }
     end
   end
end
