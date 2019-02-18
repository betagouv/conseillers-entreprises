class CreateSolicitations < ActiveRecord::Migration[5.2]
  def change
    create_table :solicitations do |t|
      t.string :description
      t.string :email
      t.string :phone_number
      t.jsonb :needs, default: {}
      t.jsonb :form_info, default: {}

      t.timestamps
    end
  end
end
