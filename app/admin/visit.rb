# frozen_string_literal: true

ActiveAdmin.register Visit do
  menu priority: 3
  permit_params :advisor_id, :visitee_id, :happened_at, :siret
end
