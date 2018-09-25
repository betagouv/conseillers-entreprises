require 'rails_helper'

RSpec.describe Feedback, type: :model do
  it do
    is_expected.to belong_to :match
  end
end
