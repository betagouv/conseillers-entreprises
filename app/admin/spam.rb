ActiveAdmin.register Spam do
  menu parent: :solicitations, priority: 1

  permit_params :email
end
