class AddBassinEmploiToTerritory < ActiveRecord::Migration[5.2]
  def up
    add_column :territories, :bassin_emploi, :boolean, default: false, null: false

    Territory.where('"name" LIKE ?', 'ZE%').update(bassin_emploi: true)
    Territory.where(name: "Arrondissement Abbeville").update(bassin_emploi: true)
  end

  def down
    remove_column :territories, :bassin_emploi
  end
end
