# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel t('active_admin.dashboard_welcome.invite_users') do
          form action: send_invitation_emails_admin_users_path, method: :post do
            table do
              %w[email first_name last_name institution role phone_number].each do |attribute|
                tr do
                  td { label(for: attribute) { t("activerecord.attributes.user.#{attribute}") } }
                  td { input id: attribute, type: 'text', name: attribute }
                end
              end
            end
            input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s
            input type: 'submit'
          end
        end
      end
    end

    columns do
      date_range = (Time.now - 30.days)..Time.now
      column do
        panel I18n.t('active_admin.dashboard_welcome.activity')do
          table do
            diagnoses_in_range = Diagnosis.where(created_at: date_range)
            selected_experts_in_range = SelectedAssistanceExpert.where(taken_care_of_at: date_range)
            needs_in_range = DiagnosedNeed.where(created_at: date_range)
            rows = {
                "activity_visits_2": diagnoses_in_range.after_step(2),
                "activity_match_taken_care_of": selected_experts_in_range.with_status([:taking_care, :done]),
                "activity_match_done": selected_experts_in_range.with_status(:done),
                "activity_match_not_for_me": selected_experts_in_range.with_status(:not_for_me),
                "activity_diagnosed_needs": needs_in_range,
                "activity_diagnosed_needs_notified": needs_in_range.joins(:diagnosis).merge(Diagnosis.where(step: 5))
            }
            rows.each do |k, v|
              tr class: 'row' do
                td I18n.t("active_admin.dashboard_welcome.#{k}")
                td v.count
              end
            end
          end
        end
      end

      column do
        panel I18n.t('active_admin.dashboard_welcome.users_activity') do
          table do
            users = User.not_admin
            rows = {
                'users_registered_total': users,
                'users_registered_recent': users.where(created_at: date_range),
                'users_searches': users.active_searchers(date_range),
                'users_visits_2': users.active_diagnosers(date_range, 2),
                'users_match_taken_care_of': users.active_answered(date_range, [:taking_care, :done]),
                'users_match_done': users.active_answered(date_range, :done)
            }

            rows.each do |k, v|
              tr class: 'row' do
                td I18n.t("active_admin.dashboard_welcome.#{k}")
                td v.count
              end
            end

          end
        end
      end
    end
  end
end
