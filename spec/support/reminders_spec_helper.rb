module RemindersSpecHelper
  def create_experts_for_reminders
    # Expert avec plus de 2 besoins de plus de 15 jours en attente
    # et avec un stock de plus de 5 besoins non pris en charge
    let!(:expert_with_many_old_quo_matches) { create :expert_with_users, :with_reminders_register }
    let!(:quo_matches_1) { create_list :match, 4, status: :quo, expert: expert_with_many_old_quo_matches }
    let!(:many_old_quo_maches) { travel_to(16.days.ago) { create_list :match, 2, status: :quo, expert: expert_with_many_old_quo_matches } }

    # Expert avec plus de 2 besoins de plus de 45 jours en attente
    # et avec un stock de plus de 5 besoins non pris en charge
    let!(:expert_with_many_abandoned_matches) { create :expert_with_users, :with_reminders_register }
    let!(:abandoned_matches_1) { create_list :match, 4, status: :quo, expert: expert_with_many_abandoned_matches }
    let!(:many_old_abandoned_maches) { travel_to(46.days.ago) { create_list :match, 2, status: :quo, expert: expert_with_many_abandoned_matches } }

    # Expert moins de 2 besoins de plus de 15 jours en attente
    # et avec un stock de plus de 5 besoins non pris en charge
    let!(:expert_with_many_quo_matches) { create :expert_with_users, :with_reminders_register }
    let!(:quo_matches_2) { travel_to(16.days.ago) { create_list :match, 1, status: :quo, expert: expert_with_many_quo_matches } }
    let!(:many_quo_matches) { create_list :match, 5, status: :quo, expert: expert_with_many_quo_matches }

    # Expert avec plus de 2 besoins de plus de 15 jours en attente
    # et avec un stock > 2 < 5 de besoins non pris en charge
    let!(:expert_with_medium_old_quo_matches) { create :expert_with_users, :with_reminders_register }
    let!(:quo_matches_3) { create_list :match, 2, status: :quo, expert: expert_with_medium_old_quo_matches }
    let!(:medium_old_quo_matches) { travel_to(16.days.ago) { create_list :match, 2, status: :quo, expert: expert_with_medium_old_quo_matches } }

    # Expert avec plus de 2 besoins de plus de 45 jours en attente
    # et avec un stock > 2 < 5 de besoins non pris en charge
    let!(:expert_with_medium_abandoned_matches) { create :expert_with_users, :with_reminders_register }
    let!(:quo_matches_4) { create_list :match, 2, status: :quo, expert: expert_with_medium_abandoned_matches }
    let!(:medium_abandoned_matches) { travel_to(45.days.ago) { create_list :match, 2, status: :quo, expert: expert_with_medium_abandoned_matches } }

    # Expert moins de 2 besoins de plus de 15 jours en attente
    # et avec un stock > 2 < 5 de besoins non pris en charge
    let!(:expert_with_medium_quo_matches) { create :expert_with_users, :with_reminders_register }
    let!(:medium_quo_matches) { create_list :match, 4, status: :quo, expert: expert_with_medium_quo_matches }
    let!(:medium_old_quo_matches_2) { travel_to(16.days.ago) { create :match, status: :quo, expert: expert_with_medium_quo_matches } }

    # Expert avec 1 besoin de plus de 15 jours avec plus de 3 mois depuis le dernier besoin cloturé
    let!(:expert_with_one_old_quo_match) { create :expert_with_users, :with_reminders_register }
    let!(:old_quo_matches) { travel_to(16.days.ago) { create :match, status: :quo, expert: expert_with_one_old_quo_match } }
    let!(:old_done_matches_1) { travel_to(4.months.ago) { create :match, status: :done, expert: expert_with_one_old_quo_match } }

    # Expert avec 1 besoin de moins de 15 jours avec moins de 3 mois depuis le dernier besoin cloturé
    let!(:expert_with_one_quo_match) { create :expert_with_users, :with_reminders_register }
    let!(:old_quo_matches_1) { create :match, status: :quo, expert: expert_with_one_quo_match }
    let!(:old_done_matches_4) { travel_to(2.months.ago) { create :match, status: :done, expert: expert_with_one_quo_match } }

    # Expert avec 1 besoin de plus de 45 jours avec plus de 3 mois depuis le dernier besoin cloturé
    let!(:expert_with_one_abandoned_match) { create :expert_with_users, :with_reminders_register }
    let!(:old_quo_match) { travel_to(45.days.ago) { create :match, status: :quo, expert: expert_with_one_abandoned_match } }
    let!(:old_done_matches_2) { travel_to(4.months.ago) { create :match, status: :done, expert: expert_with_one_abandoned_match } }

    # Expert avec 1 besoin de moins de 15 jours avec plus de 3 mois depuis le dernier besoin cloturé
    let!(:expert_with_one_quo_match_1) { create :expert_with_users, :with_reminders_register }
    let!(:quo_match) { create :match, status: :quo, expert: expert_with_one_quo_match_1 }
    let!(:old_done_matches_3) { travel_to(4.months.ago) { create :match, status: :done, expert: expert_with_one_quo_match_1 } }
  end

  def create_registers_for_reminders
    # Expert deja présent la semaine passée, vu, et avec encore des besoins en attentes
    let!(:expert_remainder) { create :expert_with_users }
    let!(:rg_expert_remainder) { create :reminders_register, expert: expert_remainder, category: :input, processed: true, run_number: 1 }
    let!(:expert_remainder_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :quo, expert: expert_remainder } }

    # Expert deja présent la semaine passée dans les inputs, pas vu, et avec encore des besoins en attentes
    let!(:expert_remainder_not_processed) { create :expert_with_users }
    let!(:rg_expert_remainder_not_processed) { create :reminders_register, expert: expert_remainder_not_processed, category: :input, run_number: 1 }
    let!(:expert_remainder_not_processed_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :quo, expert: expert_remainder_not_processed } }

    # Expert deja présent la semaine passée dans les paniers, pas vu, et avec encore des besoins en attentes
    let!(:expert_remainder_category) { create :expert_with_users }
    let!(:rg_expert_remainder_category) { create :reminders_register, expert: expert_remainder_category, category: :remainder, run_number: 1 }
    let!(:expert_remainder_category_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :quo, expert: expert_remainder_category } }

    # Expert entrant dans les relances pas vu
    let!(:expert_input) { create :expert_with_users, reminders_registers: [] }
    let!(:expert_input_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :quo, expert: expert_input } }

    # Expert entrant vu
    let!(:expert_input_processed) { create :expert_with_users }
    let!(:rg_expert_input_processed) { create :reminders_register, expert: expert_input_processed, category: :input, processed: true, run_number: 1 }
    let!(:expert_input_processed_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :quo, expert: expert_input_processed } }

    # Expert sortant pas vu
    let!(:expert_output_not_seen) { create :expert_with_users }
    let!(:rg_expert_output_not_seen) { create :reminders_register, expert: expert_output_not_seen, run_number: 1 }
    let!(:expert_output_not_seen_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :done, expert: expert_output_not_seen } }

    # Expert sortant present depuis longtemps pas vu
    let!(:old_expert_output_not_seen) { create :expert_with_users }
    let!(:rg_old_expert_output_not_seen) { create :reminders_register, created_at: 1.month.ago, category: :output, expert: old_expert_output_not_seen, run_number: 1 }
    let!(:old_expert_output_not_seen_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :done, expert: old_expert_output_not_seen } }

    # Expert dans les sorties sortant vu
    let!(:expert_output) { create :expert_with_users }
    let!(:rg_expert_output) { create :reminders_register, expert: expert_output, processed: true, category: :output, run_number: 1 }
    let!(:expert_output_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :done, expert: expert_output } }

    # Expert dans les entrées sortant vu
    let!(:expert_input_to_output) { create :expert_with_users }
    let!(:rg_expert_input_to_output) { create :reminders_register, expert: expert_input_to_output, processed: true, category: :input, run_number: 1 }
    let!(:expert_input_to_output_needs) { travel_to(16.days.ago) { create_list :match, 6, status: :done, expert: expert_input_to_output } }
  end
end
