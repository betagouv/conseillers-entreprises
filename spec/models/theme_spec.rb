# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Theme do
  subject { build :theme }

  it { is_expected.to validate_presence_of :label }
  it { is_expected.to validate_uniqueness_of :label }
end
