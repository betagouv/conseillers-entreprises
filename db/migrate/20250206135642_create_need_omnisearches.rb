class CreateNeedOmnisearches < ActiveRecord::Migration[7.2]
  def change
    create_view :need_omnisearches, materialized: true
    add_index :need_omnisearches, :tsv_document, using: :gin
  end
end
