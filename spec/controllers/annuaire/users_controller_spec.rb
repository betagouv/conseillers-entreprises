require 'rails_helper'
require 'api_helper'

RSpec.describe Annuaire::UsersController do
  login_admin

  describe '#POST send_invitations' do
    let(:institution) { create :institution }
    let!(:antenne) { create :antenne, institution: institution }
    let!(:user) { create :user, antenne: antenne, invitation_sent_at: nil }
    let(:one_day_ago) { 1.day.ago }
    let!(:old_user) { create :user, antenne: antenne, invitation_sent_at: one_day_ago }

    subject(:request) { post :send_invitations, params: { institution_slug: institution.slug, users_ids: "#{user.id} #{old_user.id}" } }

    before { request }

    it 'expect invitation sent to user' do
      expect(user.reload.invitation_sent_at).not_to be_nil
    end

    it 'don’t invite user which have already accept the invitation' do
      expect(old_user.reload.invitation_sent_at.beginning_of_hour).to eq one_day_ago.beginning_of_hour
    end
  end
end
