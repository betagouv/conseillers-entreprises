class AddUniqueIndexesToMakeRubocopHappy < ActiveRecord::Migration[6.0]
  def change
    add_index :companies, :siren, unique: true, where: 'siren != NULL'
    add_index :facilities, :siret, unique: true, where: 'siret != NULL'
    add_index :matches, [:expert_id, :need_id], unique: true, where: 'expert_id != NULL'
    add_index :needs, [:subject_id, :diagnosis_id], unique: true
    add_index :themes, :label, unique: true
  end
end
