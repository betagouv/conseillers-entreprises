require 'rails_helper'

RSpec.describe Theme do
  subject { build :theme }

  it do
    is_expected.to have_many(:subjects)
    is_expected.to have_many(:territorial_zones)
  end

  it { is_expected.to validate_presence_of :label }
  it { is_expected.to validate_uniqueness_of :label }
end
