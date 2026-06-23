class CreateSolicitationMailTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :solicitation_mail_templates do |t|
      t.string :email_type, null: false
      t.text :body_html, null: false
      t.timestamps
    end

    add_index :solicitation_mail_templates, :email_type, unique: true
  end
end
