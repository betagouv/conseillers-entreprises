class AdminMailerPreview < ActionMailer::Preview
  def weekly_statistics
    public_stats_counts = {
      params: {
        start_date: 1.week.ago.to_date,
        end_date: Date.today
      },
      counts: {
        solicitations: '80',
        solicitations_diagnoses: '85%',
        exchange_with_expert: '87%',
        taking_care: '100%'
      }
    }
    reminders_counts = {
      counts: {
        poke: 18,
        recall: 9,
        warn: 3,
        archive: 20
      }
    }

    AdminMailer.weekly_statistics(public_stats_counts, reminders_counts)
  end

  def solicitation
    params = {
      description: Faker::Hipster.paragraphs(number: 5).join('<br/>'),
      phone_number: Faker::PhoneNumber.phone_number,
      email: Faker::Internet.email,
      form_info: {
        pk_campaign: "test",
        slug: 'brexit',
      }
    }
    solicitation = Solicitation.last
    solicitation.assign_attributes(params)
    AdminMailer.solicitation(solicitation)
  end
end
