require 'rails_helper'

RSpec.describe Badge, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :color }
  end
end
