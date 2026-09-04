require 'rails_helper'

RSpec.describe HomeEmphasis do
  describe '#set_unique_emphasis_item' do
    before do
      create_list(:landing, 5)
      create_list(:landing_subject, 5)
    end

    it do
      expect(described_class.home_emphasis_item).to be_nil

      landing = Landing.first
      landing.update!(emphasis: true)

      expect(described_class.home_emphasis_item).to eq landing

      landing_subject = LandingSubject.first
      landing_subject.update!(emphasis: true)

      expect(described_class.home_emphasis_item).to eq landing_subject
      expect(landing.reload.emphasis).to be false
      expect(landing_subject.reload.emphasis).to be true

      landing.update!(emphasis: true)

      expect(described_class.home_emphasis_item).to eq landing
      expect(landing.reload.emphasis).to be true
      expect(landing_subject.reload.emphasis).to be false

      landing.update!(emphasis: false)

      expect(described_class.home_emphasis_item).to be_nil
      expect(landing.reload.emphasis).to be false
      expect(landing_subject.reload.emphasis).to be false
    end
  end
end
