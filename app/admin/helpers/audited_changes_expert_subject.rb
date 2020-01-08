module Admin
  module Helpers
    module AuditedChangesExpertSubject
      def admin_changes(klass)
        self.send(klass.to_s.underscore).html_safe
      end

      def expert_subject
        html = ""
        if audited_changes['role'].is_a?(Array)
          last_role = "active_admin.resource.index.role_#{audited_changes['role'].first}"
          new_role = "active_admin.resource.index.role_#{audited_changes['role'].last}"
          html << "<div><strong>#{I18n.t('active_admin.resource.index.role')}</strong>
            <span> : #{I18n.t(last_role)}</span><span> ➔</span>
            <span>#{I18n.t(new_role)}</span></div>"
        end
        if audited_changes['description'].is_a?(Array)
          html << "<div><strong>#{I18n.t('active_admin.resource.index.description')}</strong><span> :
            #{I18n.t('active_admin.resource.index.description_changes', old: audited_changes['description'].first, new: audited_changes['description'].last)}</span></div>"
        end
        html
      end
    end

    Audited::Audit.include AuditedChangesExpertSubject
  end
end
