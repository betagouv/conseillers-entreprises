class CreateThemesTerritories < ActiveRecord::Migration[7.0]
  def change
    create_table :territories_themes do |t|
      t.references :theme, null: false, foreign_key: true
      t.references :territory, null: false, foreign_key: true

      t.timestamps
    end

    up_only do
      # "Problématiques de ressources humaines" -> Occitanie
      # "Problématiques des organismes de formation" -> Aura
      [
        { theme: 55, region: 133 },
        { theme: 53, region: 137 },
      ].each do |hash|
        theme = Theme.find_by(id: hash[:theme])
        territory = Territory.find_by(id: hash[:region])

        if theme && territory
          theme.territories << territory
        end
      end
    end
  end
end
