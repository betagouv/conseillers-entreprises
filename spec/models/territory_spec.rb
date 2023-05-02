# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territory do
  describe 'validations' do
    it do
      is_expected.to have_and_belong_to_many :communes
    end
  end

  describe 'join_geometry' do
    let!(:territory1) { create :territory, :region, :geometry }

    it 'finds the geometry' do
      territory = Territory.where(id: territory1.id).join_geometry.first

      expect(territory).not_to be_nil
      expect(territory.wkb_geometry).not_to be_empty
      expect(territory.wkb_geometry.area).to eq 1
    end
  end
end
