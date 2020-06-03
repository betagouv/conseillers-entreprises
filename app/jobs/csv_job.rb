# frozen_string_literal: true

class CsvJob < ApplicationJob
  def perform(model, user)
    file = CsvExportService.build(model)
    AdminMailer.send_csv(model, file, user).deliver_now
    file.unlink
  end
end
