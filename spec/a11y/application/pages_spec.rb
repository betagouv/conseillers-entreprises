# frozen_string_literal: true

require 'rails_helper'

describe 'pages', type: :feature, js: true do
  login_user

  subject { page }

  describe '/tutoriels' do
    before { visit '/tutoriels' }

    it { is_expected.to be_accessible }
  end
end
