class AdminMailerPreview < ActionMailer::Preview
  def weekly_statistics
    @not_admin_diagnoses = Diagnosis
      .includes([:advisor, facility: [:company]])
      .archived(false)
      .where(advisor: User.not_admin)
      .order(created_at: :desc)
    @completed_diagnoses = @not_admin_diagnoses.completed.updated_last_week
    created_diagnoses = @not_admin_diagnoses.in_progress.created_last_week

    recently_signed_up_users = User.created_last_week
    updated_diagnoses = @not_admin_diagnoses.in_progress.updated_last_week
    updated_diagnoses = updated_diagnoses.where('diagnoses.created_at < ?', 1.week.ago)

    hash = {
      signed_up_users: {
        count: recently_signed_up_users.count,
        items: recently_signed_up_users
      },
      created_diagnoses: {
        count: created_diagnoses.count,
        items: created_diagnoses
      },
      updated_diagnoses: {
        count: updated_diagnoses.count,
        items: updated_diagnoses
      },
      completed_diagnoses: {
        count: @completed_diagnoses.count,
        items: @completed_diagnoses
      },
      quo_not_taken_after_3_weeks: Need.quo_not_taken_after_3_weeks.count,
      taken_not_done_after_3_weeks: Need.taken_not_done_after_3_weeks.count,
      rejected: Need.rejected.count,
      matches_count: 12
    }
    AdminMailer.weekly_statistics(hash)
  end

  def solicitation
    localized_needs_keypath = 'solicitations.needs.short'
    all_needs = I18n.t(localized_needs_keypath).keys

    params = {
      description: Faker::Hipster.paragraphs(5).join('<br/>'),
      phone_number: Faker::PhoneNumber.phone_number,
      email: Faker::Internet.email,
      needs: all_needs.map{ |n| [n, rand(2).to_s] }.to_h,
      form_info: {
        alternative: "index_a",
        pk_campaign: "test"
      }
    }
    solicitation = Solicitation.last
    solicitation.assign_attributes(params)
    AdminMailer.solicitation(solicitation)
  end

  private

  def match_with_person
    Match.where.not(relay: nil).or(Match.where.not(expert_skill: nil)).sample
  end
end
