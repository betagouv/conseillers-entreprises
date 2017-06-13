# frozen_string_literal: true

ActiveAdmin.register Visit do
  menu priority: 3
  permit_params :advisor, :visitee, :happened_at, :siret
end
