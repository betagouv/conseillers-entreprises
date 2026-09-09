# == Schema Information
#
# Table name: file_imports
#
#  id             :bigint(8)        not null, primary key
#  entity         :enum             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)        not null
#  user_id        :bigint(8)        not null
#
# Indexes
#
#  index_file_imports_on_institution_id  (institution_id)
#  index_file_imports_on_user_id         (user_id)
#
class FileImport < ApplicationRecord
  belongs_to :user
  belongs_to :institution

  has_one_attached :file

  def entity_klass = entity.constantize

  def import(preview)
    file.open do |f|
      entity_klass.import_csv(f, preview: preview, institution: institution)
      # how do I store result? preprocess and postprocess errors are easy, but
      # objects.errors is the interesting stuff.
      # wait I don't need to, since I just imported
    end
  end
end
