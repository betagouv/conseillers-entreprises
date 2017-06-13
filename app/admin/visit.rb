ActiveAdmin.register Visit do
  menu priority: 3
  permit_params :advisor, :visitee, :happened_at, :siret
end
