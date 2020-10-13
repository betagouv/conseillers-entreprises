# frozen_string_literal: true

class CsvJob < ApplicationJob
  def perform(model, ransack_params, user)
    klass = model.constantize
    relation = klass.ransack(ransack_params).result
    file = relation.export_csv.build_file
    AdminMailer.send_csv(model, ransack_params, file, user).deliver_now
    file.unlink
  end
end
