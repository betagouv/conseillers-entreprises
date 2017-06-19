# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailtoLog, type: :model do
  it do
    is_expected.to belong_to :question
    is_expected.to belong_to :visit
    is_expected.to belong_to :assistance
    is_expected.to validate_presence_of :question
    is_expected.to validate_presence_of :visit
  end
end
