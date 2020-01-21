module Admin
  module Helpers
    module AuditedChanges
      def admin_changes
        klass = self.auditable_type.constantize
        changes = self.audited_changes
        changes.map do |k, v|
          next unless v.is_a?(Array) && !v.is_a?(Integer)
          [
            klass.human_attribute_name(k) + ' : ' +
            klass.human_attribute_name(k + '.' + klass.attribute_types[k].cast(v.first).to_s) + ' ➔ ' +
            klass.human_attribute_name(k + '.' + klass.attribute_types[k].cast(v.last).to_s)
          ]
        end
      end
    end

    Audited::Audit.include AuditedChanges
  end
end
