# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { is_expected.to belong_to :parent_question }
  it { is_expected.to have_one :child_question }
  it { is_expected.to validate_presence_of :parent_question }
end
