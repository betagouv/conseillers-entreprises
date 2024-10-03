class AddCooperationToThemes < ActiveRecord::Migration[7.0]
  def change
    add_column :themes, :cooperation, :boolean, default: false

    up_only do
      cooperation_labels = [
        "Brexit","Problématiques des travailleurs indépendants handicapés","Problématiques de ressources humaines",
        "Problématiques des fournisseurs des ministères économiques et financiers","Problématiques des organismes de formation"
      ]
      Theme.where(label: cooperation_labels).update_all(cooperation: true)
    end
  end
end
