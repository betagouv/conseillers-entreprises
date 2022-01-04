module Admin
  module Helpers
    module Links
      def needs_links(needs)
        needs.map do |need|
          I18n.t('active_admin.solicitations.need_show') + link_to(need.subject.label, need_path(need))
        end.join('</br>')
      end

      def diagnosis_link(diagnosis)
        if diagnosis.present?
          link = "#{I18n.t('activerecord.models.diagnosis.one')} : #{admin_link_to(diagnosis)}"
          link += I18n.t('active_admin.solicitations.diagnosis_in_progress') unless diagnosis.step_completed?
        end
        link
      end
    end

    Arbre::Element.include Links
  end
end
