# frozen_string_literal: true

class Expert < ApplicationRecord
  include PersonConcern

  belongs_to :institution

  validates :institution, presence: true
end
