# frozen_string_literal: true

require 'rails_helper'

describe 'territory users feature', type: :feature do
  login_user

  let(:facility) { create :facility }
  let(:diagnosis_visit) { create :visit, :with_visitee, facility: facility }
  let(:diagnosis) { create :diagnosis, visit: diagnosis_visit }
  let!(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

  before do
    territory = create :territory
    territory_user = create :territory_user, user: current_user, territory: territory
    create :territory_city, city_code: facility.city_code, territory: territory

    create :selected_assistance_expert, territory_user: territory_user, diagnosed_need: diagnosed_need, status: :quo

    visit diagnosis_territory_users_path(diagnosis_id: diagnosis.id)
  end

  it 'displays diagnosis page' do
    expect(page).to have_content(diagnosed_need.question)
    expect(page).to have_content(I18n.t('experts.expert_buttons.i_take_care'))
    expect(page).to have_content(I18n.t('experts.expert_buttons.not_for_me'))
  end
end
