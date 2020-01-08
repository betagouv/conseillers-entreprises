module Admin
  module Helpers
    module AuditedDescriptionExpertSubject
      def admin_description
        "<div><a href='subjects/#{subject.id}'>#{subject}</a></div>
         <div>#{institution_subject.description}</div>
         <div>#{description}</div>".html_safe
      end
    end

    ExpertSubject.include AuditedDescriptionExpertSubject
  end
end
