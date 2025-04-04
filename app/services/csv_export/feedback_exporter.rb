module CsvExport
  class FeedbackExporter < BaseExporter
    def initialize(relation, options = nil)
      super
      @relation = Match
        .joins(need: :feedbacks, expert: { users: :feedbacks })
        .where(needs: { feedbacks: relation }, experts: { users: { feedbacks: relation } })
        .distinct
    end

    def fields
      {
        solicitation_provenance_category: -> { I18n.t(solicitation.provenance_category, scope: %i(solicitation provenance_categories)) if solicitation&.provenance_category.present? },
        solicitation_provenance_title: -> { solicitation&.provenance_title },
        solicitation_provenance_detail: -> { solicitation&.provenance_detail },
        need_id: -> { need&.id },
        need_created_at:  -> { I18n.l(need.created_at, format: :admin) },
        siret: -> { facility.siret },
        real_theme: :theme,
        real_subject: :subject,
        need_status: -> { need.human_attribute_value(:status, context: :csv) },
        need_closed_at: -> { I18n.l(need.matches.minimum(:closed_at), format: :admin) if need.matches.pluck(:closed_at).compact.present? },
        match_status: -> { human_attribute_value(:status, context: :short) },
        match_closed_at: -> { I18n.l(closed_at, format: :admin) if closed_at.present? },
        expert_antenne: :expert_antenne,
        expert_institution: :expert_institution,
        comments: -> { FeedbackExporter.display_comments(expert, need) },
        satisfaction_contacted_by_expert: -> { I18n.t(company_satisfaction.contacted_by_expert, scope: [:boolean, :text]) if company_satisfaction.present? },
        satisfaction_useful_exchange: -> { I18n.t(company_satisfaction.useful_exchange, scope: [:boolean, :text]) if company_satisfaction.present? },
        satisfaction_comment: -> { company_satisfaction&.comment },
        page_besoin: -> { Rails.application.routes.url_helpers.need_url(self.need) }
      }
    end

    def preloaded_associations
      [
        :need, :facility, :company, :expert, :expert_antenne, :expert_institution, :theme, :solicitation, :company_satisfaction
      ]
    end

    def sort_relation(relation)
      relation.includes(*preloaded_associations).sort_by{ |m| [(m.solicitation&.created_at || m.created_at), m.created_at] }
    end

    def filename
      "commentaires-#{Time.zone.now.iso8601}"
    end

    # Class method to prevent "undefined method `display_comments' for Match:Class"
    def self.display_comments(expert, need)
      comments = expert.feedbacks.where(user: expert.users, feedbackable: need).order(:created_at)
      comments_displays = comments.map do |comment|
        "- #{I18n.l(comment.created_at, format: :fr)}, #{comment.user.full_name}: #{comment.description}"
      end
      comments_displays.join("\n")
    end
  end
end
