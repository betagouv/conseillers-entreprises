module Admin
  module Helpers
    module Links
      def needs_links(needs)
        needs_links = needs.map do |need|
          I18n.t('active_admin.solicitations.need_show') + link_to(need.subject.label, need_path(need))
        end
        needs_links.join('</br>')
      end

      def diagnosis_link(diagnosis)
        if diagnosis&.step_completed?
          "#{I18n.t('activerecord.models.diagnosis.one')} : #{admin_link_to(diagnosis)}"
        elsif diagnosis.present? && !diagnosis.step_completed?
          "#{I18n.t('activerecord.models.diagnosis.one')} : #{admin_link_to(diagnosis)} #{I18n.t('active_admin.solicitations.diagnosis_in_progress')}"
        end
      end
    end

    Arbre::Element.include Links
  end
end
