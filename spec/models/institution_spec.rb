# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Institution, type: :model do
  it { is_expected.to validate_presence_of :name }

  describe 'to_s' do
    it do
      institution = create :institution, name: 'Direccte'
      expect(institution.to_s).to eq 'Direccte'
    end
  end
end
