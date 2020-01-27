module Admin
  module Helpers
    module AuditedExpert
      def admin_description
        Expert.human_attribute_name(:subjects_reviewed_at)
      end
    end

    module AuditedExpertSubject
      def admin_description
        if persisted?
          "<div><a href='subjects/#{subject.id}'>#{subject}</a></div>
           <div>#{institution_subject.description}</div>
           <div>#{description}</div>".html_safe
        end
      end
    end

    Expert.include AuditedExpert
    ExpertSubject.include AuditedExpertSubject
  end
end
