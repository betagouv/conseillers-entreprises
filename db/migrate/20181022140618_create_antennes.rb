class CreateAntennes < ActiveRecord::Migration[5.2]
  def change
    create_table :antennes do |t|
      t.string :name
      t.belongs_to :institution

      t.timestamps
    end

    create_join_table :antennes, :communes, table_name: :intervention_zones do |t|
      t.references :antenne, index: true, null: false, foreign_key: true
      t.references :commune, index: true, null: false, foreign_key: true
    end

    change_table :experts do |t|
      t.belongs_to :antenne
    end

    change_table :users do |t|
      t.belongs_to :antenne
    end
  end
end
