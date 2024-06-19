# frozen_string_literal: true

require 'rails_helper'

describe 'shared_satisfactions', :js, type: :feature do
  before { create_home_landing }
  login_user

  subject { page }

  let(:expert) { create :expert, users: [current_user] }
  let(:need) { create :need, matches: [ create(:match, status: :done, expert: expert) ] }
  let(:company_satisfaction) { create :company_satisfaction, need: need }
  
  describe '/conseiller/retours/nouveaux' do
    let!(:unseen_satisfaction) { create :shared_satisfaction, company_satisfaction: company_satisfaction, user: current_user, seen_at: nil }
    
    before { visit '/conseiller/retours/nouveaux' }

    it { is_expected.to be_accessible }
  end

  describe '/conseiller/retours/vus' do
    let!(:seen_satisfaction) { create :shared_satisfaction, company_satisfaction: company_satisfaction,  user: current_user, seen_at: Time.zone.now }

    before { visit '/conseiller/retours/vus' }

    it { is_expected.to be_accessible }
  end
end
