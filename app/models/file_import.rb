# == Schema Information
#
# Table name: file_imports
#
#  id                :bigint(8)        not null, primary key
#  entity            :enum             not null
#  result_object_ids :bigint(8)        default([]), not null, is an Array
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  author_id         :bigint(8)        not null
#  institution_id    :bigint(8)        not null
#
# Indexes
#
#  index_file_imports_on_author_id       (author_id)
#  index_file_imports_on_institution_id  (institution_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
class FileImport < ApplicationRecord
  ## Relations
  # belongs_to :parent_antenne, class_name: 'Antenne', inverse_of: :child_antennes, optional: true
  belongs_to :author, class_name: 'User'
  belongs_to :institution
  has_one_attached :file

  ## Attributes
  enum :entity, [User, Antenne].index_with(&:to_s)

  def importer_klass = CsvImport.const_get("#{entity}Importer")

  def import(commit:, &block)
    raise "Can’t reimport the same record" if completed?

    file.open do |f|
      result = importer_klass.import(f, institution: institution, commit: commit, &block)
      self.update(result_object_ids: result.objects.map(&:id)) if commit
      result
    end
  end

  def completed? = result_objects.present?

  ## Access the root imported objects
  def result_objects = entity.where(id: result_object_ids)

  ## Auto-destroy the file (and the record) a week after it’s imported.
  after_update :auto_destroy, if: -> { result_object_ids.present? }

  DESTROY_DELAY = 1.week

  def auto_destroy = DestroyJob.set(wait: DESTROY_DELAY).perform_later(self)

  class DestroyJob < ApplicationJob
    def perform(file_import) = file_import.destroy
  end
end
