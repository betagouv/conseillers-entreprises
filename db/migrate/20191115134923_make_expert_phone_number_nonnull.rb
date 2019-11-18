class MakeExpertPhoneNumberNonnull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :experts, :phone_number, false
  end
end
