# frozen_string_literal: true

ActiveAdmin.register MailtoLog do
  menu parent: :questions, priority: 3
  actions :index, :show
end
