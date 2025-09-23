require 'rails_helper'

RSpec.describe Territory do
  describe 'validations' do
    it do
      is_expected.to have_and_belong_to_many :communes
      is_expected.to have_and_belong_to_many :themes
    end
  end
end
