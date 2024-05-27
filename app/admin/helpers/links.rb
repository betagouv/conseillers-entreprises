module Admin
  module Helpers
    module Links
      def needs_links(needs)
        needs.map do |need|
          I18n.t('active_admin.solicitations.need_show') + link_to(need.subject.label, need_path(need))
        end.join('<br/>')
      end

      def diagnosis_link(diagnosis)
        if diagnosis.present?
          link = "#{I18n.t('activerecord.models.diagnosis.one')} : #{admin_link_to(diagnosis)}"
          link += I18n.t('active_admin.solicitations.diagnosis_in_progress') unless diagnosis.step_completed?
        end
        link
      end

      def shared_satisfactions_links(shared_satisfactions)
        shared_satisfactions.map do |us|
          user = us.user
          "#{admin_link_to us.company_satisfaction.done_experts.joins(:users).where(users: user).first} - #{admin_link_to user}"
        end.join('<br/>')
      end

      def admin_link_to_expert_shared_satisfaction(e)
        count = e.shared_company_satisfactions.count
        if count > 0
          text = "#{count} #{Expert.human_attribute_name(:shared_company_satisfactions, count: count).downcase}"
          div link_to text, admin_company_satisfactions_path('q[matches_expert_id_eq]': e.id, 'q[shared_eq]': 'shared')
        end
      end
    end

    Arbre::Element.include Links
  end
end
