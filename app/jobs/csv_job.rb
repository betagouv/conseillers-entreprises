# frozen_string_literal: true

class CsvJob < ApplicationJob
  def perform(model, ransack_params, user)
    ActiveRecord::Base.transaction do
      klass = model.constantize
      relation = klass.ransack(ransack_params).result
      result = relation.export_csv
      file = result.build_file
      user.csv_exports.attach(io: File.open(file.path),
                              key: "csv_exports/#{user.full_name.parameterize}/#{result.filename}",
                              filename: result.filename,
                              content_type: 'application/csv')
      file.unlink
    end
  end
end
