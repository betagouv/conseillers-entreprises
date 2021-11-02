class AddOpcoFields < ActiveRecord::Migration[6.1]
  def up
    create_table :categories do |t|
      t.string :label, null: false
      t.timestamps
    end

    create_table :categories_institutions, id: false, force: :cascade do |t|
      t.bigint :institution_id, null: false
      t.bigint :category_id, null: false
      t.index ["category_id"], name: "index_categories_institutions_on_category_id"
      t.index ["institution_id"], name: "index_categories_institutions_on_institution_id"
    end

    add_column :institutions, :siren, :text
    add_reference :facilities, :opco, foreign_key: { to_table: :institutions }, null: true

    # Partenaires d'acquisition
    acquisition_category = Category.create(label: 'acquisition')
    Institution.where(Institution.arel_table[:name].matches("%#{"acquisition"}%")).each do |acquisition_partner|
      acquisition_partner.categories << acquisition_category
    end

    # Partenaires qui fournissent des experts
    expert_category = Category.create(label: 'expert_provider')
    Institution.where.not(Institution.arel_table[:name].matches("%#{"acquisition"}%")).each do |expert_partner|
      expert_partner.categories << expert_category
    end

    # OPCO
    opco_category = Category.create(label: 'opco')
    [
      [ "OPCO AKTO", "853000982" ],
      [ "OPCO 2i", "849813852" ],
      [ "OPCO Santé", "854033115" ],
      [ "Opcommerce", "398522243" ],
      [ "OPCO Uniformation", "309065043" ],
      [ "OPCO Mobilités", "851240499" ],
      [ "OPCO OCAPIAT", "844752006" ],
      [ "OPCO Entreprises de proximité", "879036895" ],
      [ "OPCO Construction", "533846150" ],
      [ "OPCO Atlas", "851296632" ],
      [ "OPCO Afdas", "784714008" ]
    ].each do |name, siren|
      institution = Institution.find_by(name: name)
      institution.categories << opco_category
      institution.update(siren: siren)
    end
  end

  def down
    remove_reference :facilities, :opco
    remove_column :institutions, :siren, :text
    drop_table :categories_institutions
    drop_table :categories
  end
end
