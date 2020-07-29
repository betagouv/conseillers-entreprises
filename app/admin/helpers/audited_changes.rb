module Admin
  module Helpers
    module AuditedChanges
      def admin_changes
        klass = self.auditable_type.constantize
        changes = self.audited_changes
        summary = changes.map do |attribute, value|
          # klass is the class, e.g. ExpertSubject
          # value is value (old, new, or array of both, e.g. `[0, 1]`)
          # attr is the attribute, e.g. "role"
          if value.is_a? Array
            "#{klass.human_attribute_name(attribute)} : #{klass.human_attribute_value(attribute, value.first)} ➔ #{klass.human_attribute_value(attribute, value.last)}"
          else
            "#{klass.human_attribute_name(attribute)} : #{klass.human_attribute_value(attribute, value)}"
          end
        end

        summary.compact
      end
    end

    Audited::Audit.include AuditedChanges
  end
end
