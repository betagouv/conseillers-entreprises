class CreateProfilPictures < ActiveRecord::Migration[7.0]
  def change
    create_table :profil_pictures do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :filename, null: false

      t.timestamps
    end

    up_only do
      users_names = ["Niels Julien Saint Amand", "Ludivine Baclet", "Mathieu Gens", "Christophe Lecomte", "Mélanie Camboni", "Adeline Latron"]
      users_names.each do |user_name|
        user = User.find_by(full_name: user_name)
        next if user.nil?
        ProfilPicture.create(filename: "#{user_name.split.first.parameterize}.webp", user: user)
      end
    end
  end
end
