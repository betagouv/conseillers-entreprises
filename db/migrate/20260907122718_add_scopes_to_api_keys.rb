class AddScopesToApiKeys < ActiveRecord::Migration[8.1]
  def change
    create_enum :api_key_scope, %w[landing_subjects all_subjects solicitation_creation qualification]
    add_column :api_keys, :scopes, :api_key_scope, array: true, null: false, default: []

    up_only do
      ApiKey.reset_column_information
      ApiKey.update_all(scopes: [ApiKey::LANDING_SUBJECTS, ApiKey::SOLICITATION_CREATION])
    end
  end
end
