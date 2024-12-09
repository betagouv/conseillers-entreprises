# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cooperation do
  describe 'validations' do
    it do
      is_expected.to have_many(:landings)
      is_expected.to have_many(:solicitations)
    end
  end

  describe 'to_s' do
    let!(:cooperation) { create :cooperation, name: 'Cooperation 1' }

    it { expect(cooperation.to_s).to eq('Cooperation 1') }
  end

  describe 'archive!' do
    let!(:cooperation) { create :cooperation, archived_at: nil }
    let!(:landing_01) { create :landing, :with_subjects, cooperation: cooperation, archived_at: nil }

    before { cooperation.archive! }

    it do
      expect(cooperation.archived_at).not_to be_nil
      expect(landing_01.reload.archived_at).not_to be_nil
    end
  end

  describe 'unarchive!' do
    let!(:cooperation) { create :cooperation, archived_at: 2.days.ago }
    let!(:landing_01) { create :landing, :with_subjects, cooperation: cooperation, archived_at: 2.days.ago }

    before { cooperation.unarchive! }

    it do
      expect(cooperation.archived_at).to be_nil
      expect(landing_01.reload.archived_at).to be_nil
    end
  end
end
