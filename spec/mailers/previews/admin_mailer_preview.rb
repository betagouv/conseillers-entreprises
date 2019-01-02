class AdminMailerPreview < ActionMailer::Preview
  def weekly_statistics
    associations = [visit: [:advisor, facility: [:company]]]
    @not_admin_diagnoses = Diagnosis.includes(associations).only_active.of_user(User.not_admin).order(created_at: :desc)
    @completed_diagnoses = @not_admin_diagnoses.completed.updated_last_week
    created_diagnoses = @not_admin_diagnoses.in_progress.created_last_week

    recently_signed_up_users = User.created_last_week
    updated_diagnoses = @not_admin_diagnoses.in_progress.updated_last_week
    updated_diagnoses = updated_diagnoses.where('diagnoses.created_at < ?', 1.week.ago)

    abandoned_needs = DiagnosedNeed.abandoned
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
      abandoned_needs_count: abandoned_needs.count,
      matches_count: 12
    }
    AdminMailer.weekly_statistics(hash)
  end

  def company_message
    localized_needs_keypath = 'contact.besoins.'
    all_needs = I18n.t(localized_needs_keypath).keys

    params = {
      description: Faker::Hipster.paragraph(5),
      phone_number: Faker::PhoneNumber.phone_number,
      email: Faker::Internet.email,
      besoins: all_needs.map{ |n| [n,rand(2)] }.to_h
    }
    message = CompanyMessage.new(params)
    AdminMailer.company_message(message)
  end

  private

  def match_with_person
    Match.where.not(relay: nil).or(Match.where.not(assistance_expert: nil)).sample
  end
end
