# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  it { is_expected.to have_many(:assistances).dependent(:nullify)}
  it { is_expected.to have_many(:diagnosed_needs).dependent(:nullify)}
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_presence_of :category }
end
