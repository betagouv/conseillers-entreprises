# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to validate_presence_of :user }
end
