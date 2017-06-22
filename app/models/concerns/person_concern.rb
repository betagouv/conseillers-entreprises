# frozen_string_literal: true

module PersonConcern
  extend ActiveSupport::Concern

  included do
    validates :last_name, :role, presence: true

    def full_name
      "#{first_name} #{last_name}"
    end
  end
end
