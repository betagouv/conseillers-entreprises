# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assistance, type: :model do
  it { is_expected.to belong_to :answer }
  it { is_expected.to validate_presence_of :answer }
  it { is_expected.to validate_presence_of :description }
end
