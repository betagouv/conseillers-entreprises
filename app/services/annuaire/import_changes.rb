# frozen_string_literal: true

module Annuaire
  class ImportChanges
    def initialize(old_data, import_result)
      @old_data = old_data
      @import_result = import_result
    end

    CHANGES = %i[touched updated created removed].freeze

    def user_changes(user)
      old_user = @old_data.users.find{ it.email == user.email }
      in_imported_set = @import_result.objects.find{ it.email == user.email }

      if old_user.present? && in_imported_set.present?
        if old_user.attributes.except("updated_at", "imported_at") == user.attributes.except("updated_at", "imported_at")
          :touched
        else
          :updated
        end
      elsif old_user.blank? && in_imported_set.present?
        :created
      elsif old_user&.persisted? && in_imported_set.blank?
        :removed
      end
    end

    def expert_changes(expert)
      old_expert = @old_data.experts.find{ it.email == expert.email }
      in_imported_set = @import_result.objects.flat_map(&:experts).find{ it.email == expert.email }

      if old_expert.present? && in_imported_set.present?
        :touched
      elsif old_expert.blank? && in_imported_set.present?
        :created
      elsif old_expert&.persisted? && in_imported_set.blank?
        :removed
      end
    end

    def expert_subject_change(expert, institution_subject)
      expert_subject = expert&.experts_subjects&.find{ it.institution_subject_id == institution_subject.id }

      old_expert = @old_data&.experts&.find{ it.email == expert.email }
      old_expert_subject = old_expert&.experts_subjects&.find{ it.institution_subject_id == institution_subject.id }
      expert_in_imported_set = @import_result.objects.flat_map(&:experts).find{ it.email == expert.email }
      in_imported_set = expert_in_imported_set&.experts_subjects&.find{ it.institution_subject_id == institution_subject.id }

      if old_expert_subject.present? == in_imported_set.present? # both present or both blank
        :touched
      elsif old_expert_subject.blank? && in_imported_set.present?
        :created
      elsif old_expert_subject.present? && in_imported_set.blank?
        :removed
      end
    end

    def antenne_changes(antenne)
      old_antenne = @old_data.antennes.find{ it.name == antenne.name }
      in_imported_set = @import_result.objects.flat_map(&:antenne).find{ it.name == antenne.name }

      if old_antenne.present? && in_imported_set.present?
        :touched
      elsif old_antenne.blank? && in_imported_set.present?
        :created # can't happen
      elsif old_antenne.present? && in_imported_set.blank?
        :removed
      end
    end
  end
end
