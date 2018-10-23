class RemoveEmailAndPhoneNumberFromInstitution < ActiveRecord::Migration[5.2]
  def change
    remove_column :institutions, :email, :string
    remove_column :institutions, :phone_number, :string
  end
end
