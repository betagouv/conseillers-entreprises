# == Schema Information
#
# Table name: file_imports
#
#  id                :bigint(8)        not null, primary key
#  entity            :enum             not null
#  result_object_ids :bigint(8)        default([]), not null, is an Array
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  institution_id    :bigint(8)        not null
#  user_id           :bigint(8)        not null
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

  enum :entity, [User, Antenne].index_with(&:to_s)

  def importer_klass = CsvImport.const_get("#{entity}Importer")

  def import(commit:, &block)
    raise "Can’t import the same file twice" if result_objects.present?

    file.open do |f|
      result = importer_klass.import(f, institution: institution, commit: commit, &block)
      self.update(result_object_ids: result.objects.map(&:id)) if commit
      result
    end
  end

  after_update :auto_destroy, if: -> { result_object_ids.present? }

  def result_objects = entity.where(id: result_object_ids)

  DESTROY_DELAY = 1.week

  def auto_destroy = DestroyJob.set(wait: DESTROY_DELAY).perform_later(self)

  class DestroyJob < ApplicationJob
    def perform(file_import) = file_import.destroy
  end
end
