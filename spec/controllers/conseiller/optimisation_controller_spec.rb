require 'rails_helper'

RSpec.describe Conseiller::OptimisationController do
  login_admin

  describe 'GET #quo_matches' do
    let!(:region_code) { "24" }
    let!(:insee_code) { "41269" }

    let!(:done_need_with_quo_match) { create :need, status: :done, facility: create(:facility, insee_code: insee_code) }
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
      before { get :quo_matches, params: { by_region: region_code } }

      it { expect(assigns(:needs)).to contain_exactly(done_need_with_quo_match) }
    end
  end

  describe 'GET #starred_needs' do
    let!(:starred_need) { create :need, starred_at: Time.zone.now }

    before { get :starred_needs }

    it { expect(assigns(:needs)).to contain_exactly(starred_need) }
  end

  describe 'GET #taking_care_matches' do
    let(:region_code) { "52" } # Pays de la Loire
    let!(:expert_1) { create :expert, territorial_zones: [create(:territorial_zone, :commune, code: "72007")] }
    let!(:expert_2) { create :expert }

    before do
      11.times do |index|
        create(:match, expert: expert_1, status: :taking_care, created_at: 2.months.ago, taken_care_of_at: 40.days.ago)
      end
      11.times do |index|
        create(:match, expert: expert_2, status: :taking_care, created_at: 2.months.ago, taken_care_of_at: 40.days.ago)
      end

    end

    context 'without filters' do
      before { get :taking_care_matches }

      it { expect(assigns(:experts)).to contain_exactly(expert_1, expert_2) }
    end

    context 'with filters' do
      before { get :taking_care_matches, params: { by_region: region_code } }

      it { expect(assigns(:experts)).to contain_exactly(expert_1) }
    end
  end
end
