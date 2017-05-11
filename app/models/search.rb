# frozen_string_literal: true

class Search < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
end
