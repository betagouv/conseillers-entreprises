# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cooperation do
  describe 'validations' do
    it do
      is_expected.to have_many(:landings)
      is_expected.to have_many(:solicitations)
    end
  end

  describe 'archive' do
    let!(:cooperation) { create :cooperation, archived_at: nil }
    let!(:landing_01) { create :landing, :with_subjects, cooperation: cooperation, archived_at: nil }

    before { cooperation.archive! }

    it do
      expect(cooperation.archived_at).not_to be_nil
      expect(landing_01.reload.archived_at).not_to be_nil
    end
  end
end
