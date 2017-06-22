# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diagnosis, type: :model do
  it do
    is_expected.to belong_to :visit
    is_expected.to validate_presence_of(:visit)
  end
end
