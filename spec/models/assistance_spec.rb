# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assistance, type: :model do
  it do
    is_expected.to belong_to :answer
    is_expected.to belong_to :user
    is_expected.to validate_presence_of :answer
    is_expected.to validate_presence_of :description
  end
end
