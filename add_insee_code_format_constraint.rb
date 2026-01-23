# Preview migration for adding INSEE code format constraint
class AddInseeCodeFormatConstraint < ActiveRecord::Migration[7.0]
  def change
    # Add CHECK constraint to validate INSEE code format
    # Format: 5 characters that are digits (0-9) or letters A or B
    add_check_constraint :facilities,
                         "insee_code ~ '^[0-9AB]{5}$'",
                         name: 'check_facilities_insee_code_format'

    add_check_constraint :solicitations,
                         "insee_code ~ '^[0-9AB]{5}$'",
                         name: 'check_solicitations_insee_code_format'
  end
end
