class AddSlugToSolicitation < ActiveRecord::Migration[6.0]
  def change
    add_column :solicitations, :slug, :string

    add_index :solicitations, :slug
    add_index :landings, :slug, unique: true

    # We can‘t add a foreign key: some landing slugs have been modified, can be removed, etc.
    # after solicitations have been made.
    # In fact, we don’t event want it.
    # I’m keeping this line for future reference.
    # add_foreign_key :solicitations, :landings, column: :slug, primary_key: :slug

    up_only do
      Solicitation.update_all("slug = form_info->>'slug'")
    end
  end
end
