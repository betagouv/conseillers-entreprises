ActiveAdmin.register ProfilPicture do
  menu parent: :users, priority: 1

  permit_params :filename, :user_id

  index do
    selectable_column
    id_column
    column :picture do |profil_picture|
      image_tag "equipe/portraits-emails/#{profil_picture.filename}", size: '50x50'
    end
    column :user
    column :filename
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: User.not_deleted.admin
      f.input :filename
    end
    f.actions
  end
end
