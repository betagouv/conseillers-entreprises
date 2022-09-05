# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reminders::NeedsController, type: :controller do
  login_admin

  describe 'POST #send_abandoned_email' do
    let!(:need) { create :need }

    before { post :send_abandoned_email, params: { id: need.id } }

    it 'send email and set abandoned_email_sent' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(need.reload.abandoned_email_sent).to be true
    end
  end

  describe 'POST #send_last_chance_email' do
    let!(:need) { create :need }
    let!(:a_match) { create :match, status: :quo, need: need }

    before { post :send_last_chance_email, params: { id: need.id } }

    it 'send email and set abandoned_email_sent' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(need.reload.last_chance_email_sent_at).not_to be_nil
    end
  end

  describe 'GET #not_for_me' do
    # - besoin avec 1 positionnement « refusé », et autres MER sans réponse           ko
    # - besoin avec 1 cloture « pas d’aide disponible », et autres MER sans réponse   ko
    # - besoin avec 1 cloture « injoignable », et autres MER sans réponse             ko
    # - besoin avec tous les positionnement « refusé »                                ok
    # - besoin archivé avec tous les positionnement « refusé »                        ko

    let!(:need1) { create :need_with_matches }
    let!(:need1_match) { create :match, need: need1, status: :not_for_me }
    let!(:need2) { create :need_with_matches }
    let!(:need2_match) { create :match, need: need2, status: :done_no_help }
    let!(:need3) { create :need_with_matches }
    let!(:need3_match) { create :match, need: need3, status: :done_not_reachable }
    let!(:need4) { create :need }
    let!(:need4_match1) { create :match, need: need4, status: :not_for_me }
    let!(:need4_match2) { create :match, need: need4, status: :not_for_me }
    let!(:need5) { create :need, archived_at: Time.now }
    let!(:need5_match) { create :match, need: need5, status: :not_for_me }

    before { get :not_for_me }

    it 'display only not_for_me needs' do
      expect(assigns(:needs)).to match_array [need4]
    end
  end
end
