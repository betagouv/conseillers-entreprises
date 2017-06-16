# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assistance, type: :model do
  it do
    is_expected.to belong_to :question
    is_expected.to belong_to :company
    is_expected.to belong_to :user
    is_expected.to validate_presence_of :title
    is_expected.to validate_presence_of :question
    is_expected.to validate_presence_of :company
  end
end
