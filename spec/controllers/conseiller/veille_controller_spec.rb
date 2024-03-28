# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conseiller::VeilleController do
  login_admin

  describe 'index pages' do

    describe 'GET #index' do
      subject(:request) { get :index }

      it 'redirects properly' do
        expect(request).to redirect_to(quo_matches_conseiller_veille_index_path)
      end
    end

    describe 'GET #quo_matches' do
      let!(:region) { create :territory, :region, name: "Région-01", code_region: 12345 }
      let!(:commune) { create :commune, regions: [region] }
      let!(:done_need_with_quo_match) { create :need, status: :done, facility: create(:facility, commune: commune) }
      let!(:done_match_01) { create(:match, need: done_need_with_quo_match, status: :quo, sent_at: 30.days.ago) }
      let!(:done_match_02) { create(:match, need: done_need_with_quo_match, status: :done, sent_at: 30.days.ago) }
      let!(:taking_care_need_with_quo_match) { create :need, status: :taking_care }
      let!(:taking_care_match_01) { create(:match, need: taking_care_need_with_quo_match, status: :quo, sent_at: 30.days.ago) }
      let!(:taking_care_match_02) { create(:match, need: taking_care_need_with_quo_match, status: :taking_care, sent_at: 30.days.ago) }
      let!(:done_no_help_need_with_quo_match) { create :need, status: :done_no_help }
      let!(:done_no_help_match_01) { create(:match, need: done_no_help_need_with_quo_match, status: :quo, sent_at: 30.days.ago) }
      let!(:done_no_help_match_02) { create(:match, need: done_no_help_need_with_quo_match, status: :done_no_help, sent_at: 30.days.ago) }

      context 'without filters' do
        before { get :quo_matches }

        it { expect(assigns(:needs)).to contain_exactly(done_need_with_quo_match, taking_care_need_with_quo_match, done_no_help_need_with_quo_match) }
      end

      context 'with filters' do
        before { get :quo_matches, params: { by_region: region.id } }

        it { expect(assigns(:needs)).to contain_exactly(done_need_with_quo_match) }
      end

    end

    describe 'GET #starred_needs' do
      let!(:starred_need) { create :need, starred_at: Time.zone.now }

      before { get :starred_needs }

      it { expect(assigns(:needs)).to contain_exactly(starred_need) }
    end
  end
end
