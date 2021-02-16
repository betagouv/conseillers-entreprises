# frozen_string_literal: true

require 'rails_helper'

describe 'application', type: :feature, js: true do
  subject { page.body }

  describe '/' do
    before do
      visit '/'
    end

    skip { is_expected.to be_valid_html }
  end
end
