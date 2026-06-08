module OnDemandActivityReports
  def self.included(dsl)
    ## Using `.send` because the ResourceDSL methods are (wrongly) private
    # See https://github.com/activeadmin/activeadmin/issues/3673#issuecomment-291267819
    dsl.send(:member_action, :generate_activity_report, method: :post) do
      generator = {
        cooperation: ActivityReports::CooperationStats,
        matches: ActivityReports::AntenneMatches,
        solicitations: ActivityReports::CooperationSolicitations,
        stats: ActivityReports::AntenneStats,
      }[params.expect(:type).to_sym]
      generator.new(resource).enqueue
      redirect_back_or_to collection_path, notice: t('active_admin.reports.job_started')
    end
  end

  module ActivityReportsSidebarHelpers
    def activity_report_sidebar_contents(generator)
      div do
        h4 t(generator.report_type, scope: "reports.type")
        if generator.missing_reports_periods.any?
          div t("active_admin.reports.missing_reports", count: generator.missing_reports_periods.count)
        end
        if generator.existing_reports_periods.any?
          div t("active_admin.reports.latest_report_period", period: TimeDurationService.period_name(generator.existing_reports_periods.last))
        end

        job_status = generator.job_status
        button_text = if job_status[:run_at].present?
          t("active_admin.reports.job_running")
        elsif job_status[:enqueued_at].present?
          t("active_admin.reports.job_enqueued")
        else
          t('active_admin.reports.start_job_now')
        end
        button_title = if job_status[:run_at].present?
          t("active_admin.reports.job_running_at", date: l(job_status[:run_at]))
        elsif job_status[:enqueued_at].present?
          t("active_admin.reports.job_enqueued_at", date: l(job_status[:enqueued_at]))
        else
          ""
        end
        enabled = generator.missing_reports_periods.any? && job_status.blank?
        div button_to button_text,
                      { action: :generate_activity_report, type: generator.report_type },
                      data: { confirm: activity_report_start_job_confirmation_message(generator) },
                      disabled: !enabled,
                      title: button_title
      end
    end

    def activity_report_start_job_confirmation_message(generator)
      lines = [t("active_admin.reports.start_job_now_message.warning")]

      if generator.missing_reports_periods.any?
        lines << t("active_admin.reports.start_job_now_message.missing_reports", count: generator.missing_reports_periods.count)
        lines += generator.missing_reports_periods.map{ "- #{TimeDurationService.period_name(it)}" }
      end

      if generator.expired_reports.any?
        lines << t("active_admin.reports.start_job_now_message.expireds_reports", count: generator.expired_reports.count)
        lines += generator.expired_reports.map{ "- #{it}" }
      end

      lines.join("\n")
    end
  end

  Arbre::Element.include ActivityReportsSidebarHelpers
end
