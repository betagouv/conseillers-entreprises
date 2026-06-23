ActiveAdmin.register Spam do
  menu parent: :solicitations, priority: 2

  permit_params :email
end
