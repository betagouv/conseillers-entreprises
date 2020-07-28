class AddSolicitationRequiredFieldsFlagsToLandingOption < ActiveRecord::Migration[6.0]
  def change
    attributes = %i[full_name phone_number email siret requested_help_amount location]
    attributes.each do |attribute|
      add_column :landing_options, "requires_#{attribute}", :boolean, null: false, default: false
    end

    up_only do
      current_required_fields = {
        requires_full_name: true,
        requires_phone_number: true,
        requires_email: true,
        requires_siret: true
      }
      LandingOption.update_all(current_required_fields)
    end
  end
end
