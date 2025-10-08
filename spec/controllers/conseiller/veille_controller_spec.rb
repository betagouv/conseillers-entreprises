require 'rails_helper'

RSpec.describe Conseiller::VeilleController do
  login_admin

  describe 'index pages' do
    describe 'GET #starred_needs' do
      let!(:starred_need) { create :need, starred_at: Time.zone.now }

      before { get :starred_needs }

      it { expect(assigns(:needs)).to contain_exactly(starred_need) }
    end
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
