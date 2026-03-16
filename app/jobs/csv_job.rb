class CsvJob < ApplicationJob
  def perform(model, ransack_params, user)
    ActiveRecord::Base.transaction do
      klass = model.constantize
      relation = klass.ransack(ransack_params).result
      result = relation.export_csv
      user.csv_exports.attach(io: result.io,
                              key: "csv_exports/#{user.full_name.parameterize}/#{result.filename}",
                              filename: result.filename,
                              content_type: 'application/csv')
    end
  end
end
