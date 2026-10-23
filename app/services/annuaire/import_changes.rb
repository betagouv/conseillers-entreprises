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

      css_class = if old_user.present? && in_imported_set.present?
        if old_user.attributes.except("updated_at", "imported_at") == user.attributes.except("updated_at", "imported_at")
          :touched
        else
          :updated
        end
      elsif old_user.blank? && in_imported_set.present?
        :created
      elsif old_user.present? && in_imported_set.blank?
        :removed
      end
    end

    def expert_changes(expert)
      old_expert = @old_data.experts.find{ it.email == expert.email }
      in_imported_set = @import_result.objects.flat_map(&:experts).find{it.email == expert.email}

      if old_expert.present? && in_imported_set.present?
        :touched
      elsif !old_expert.present? && in_imported_set.present?
        :created
      elsif old_expert.present? && !in_imported_set.present?
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
