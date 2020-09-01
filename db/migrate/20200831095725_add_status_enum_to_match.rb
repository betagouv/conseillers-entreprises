class AddStatusEnumToMatch < ActiveRecord::Migration[6.0]
  def change
    rename_column :matches, :status, :old_status
    create_enum "match_status", %w[quo taking_care done done_no_help done_not_reachable not_for_me]
    add_column :matches, :status, :match_status, default: "quo", null: false
    add_index :matches, :status
    Match.find_each do |match|
      match.update_columns(status: match.old_status)
    end
  end
end
