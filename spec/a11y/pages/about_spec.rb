# frozen_string_literal: true

require 'rails_helper'

describe 'about', type: :feature, js: true do
  subject { page }

  describe '/cgu' do
    before { visit '/cgu' }

    it it { is_expected.to be_accessible }
  end

  describe '/mentions_d_information' do
    before { visit '/mentions_d_information' }

    it it { is_expected.to be_accessible }
  end

  describe '/comment_ca_marche' do
    before do
      create_list :institution, 2, show_on_list: true
      visit '/comment_ca_marche'
    end

    it it { is_expected.to be_accessible }
  end

  describe '/mentions_legales' do
    before { visit '/mentions_legales' }

    it it { is_expected.to be_accessible }
  end

  describe '/accessibilite' do
    before { visit '/accessibilite' }

    it it { is_expected.to be_accessible }
  end
end
