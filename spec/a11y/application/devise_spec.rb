# frozen_string_literal: true

require 'rails_helper'

describe 'devise', type: :feature, js: true do
  subject { page }

  describe '/mon_compte/sign_in' do
    before { visit '/mon_compte/sign_in' }

    it { is_expected.to be_accessible }
  end
end
