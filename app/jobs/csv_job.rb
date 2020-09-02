# frozen_string_literal: true

class CsvJob < ApplicationJob
  def perform(model, ransack_params, user)
    klass = model.constantize
    relation = klass.ransack(ransack_params).result
    file = CsvExportService.build_file(relation)
    AdminMailer.send_csv(model, ransack_params, file, user).deliver_now
    file.unlink
  end
end
