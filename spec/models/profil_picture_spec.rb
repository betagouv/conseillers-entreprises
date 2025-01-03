require 'rails_helper'

RSpec.describe ProfilPicture do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it do
      is_expected.to validate_presence_of(:filename)
    end
  end
end
