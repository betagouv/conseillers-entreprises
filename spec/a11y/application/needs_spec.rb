# frozen_string_literal: true

require 'rails_helper'

describe 'needs', type: :feature, js: true do
  login_user

  subject { page }

  describe '/besoins/boite_de_reception' do
    before do
      create_list :match, 2, expert: current_user.experts.first
      visit '/besoins/boite_de_reception'
    end

    it { is_expected.to be_accessible }
  end
end
