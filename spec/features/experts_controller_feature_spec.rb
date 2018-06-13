# frozen_string_literal: true

require 'rails_helper'

describe 'experts feature', type: :feature do
  login_user

  let(:expert) { create :expert }
  let(:diagnosis_visit) { create :visit, :with_visitee }
  let(:diagnosis) { create :diagnosis, visit: diagnosis_visit }
  let!(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

  before do
    assistance_expert = create :assistance_expert, expert: expert

    create :match,
           assistance_expert: assistance_expert,
           diagnosed_need: diagnosed_need,
           status: :quo

    visit diagnosis_experts_path(diagnosis_id: diagnosis.id, access_token: expert.access_token)
  end

  it 'displays diagnosis page' do
    expect(page).to have_content(diagnosed_need.question)
    expect(page).to have_content(I18n.t('experts.expert_buttons.i_take_care'))
    expect(page).to have_content(I18n.t('experts.expert_buttons.not_for_me'))
  end
end
