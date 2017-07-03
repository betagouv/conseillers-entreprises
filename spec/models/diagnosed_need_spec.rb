# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosedNeed, type: :model do
  it do
    is_expected.to belong_to :diagnosis
    is_expected.to belong_to :question
    is_expected.to validate_presence_of(:diagnosis)
  end
end
