# frozen_string_literal: true

module PersonConcern
  extend ActiveSupport::Concern

  included do
    validates :full_name, :role, presence: true
    validates :email, format: { with: /\A.+@.+\..+\z/ }, allow_blank: true

    def to_s
      full_name
    end
  end
end
