class AddRightableElementsToUserRights < ActiveRecord::Migration[7.2]
  def up
    add_reference :user_rights, :rightable_element, polymorphic: true, index: true

    UserRight.find_each do |user_right|
      user_right.update(rightable_element_id: user_right.antenne_id, rightable_element_type: 'Antenne')
    end

    add_index :user_rights, [:user_id, :category, :rightable_element_id, :rightable_element_type], unique: true, name: 'unique_category_rightable_element_index'
    remove_reference :user_rights, :antenne, index: true
  end

  def down
    add_reference :user_rights, :antenne, index: true

    UserRight.find_each do |user_right|
      user_right.update(antenne: user_right.rightable_element)
    end

    remove_reference :user_rights, :rightable_element, polymorphic: true, index: true
  end
end
