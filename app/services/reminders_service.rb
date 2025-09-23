# frozen_string_literal: true

class RemindersService
  MATCHES_AGE = {
    old: 15.days.ago,
    prehistorical: 3.months.ago
  }

  MATCHES_COUNT = {
    quo: 2,
    many: 5,
    medium: 2
  }

  def initialize(experts = Expert.not_deleted.with_users.with_active_matches.left_joins(:reminders_registers))
    @experts_with_active_matches = experts
  end

  def create_reminders_registers
    last_run_number = RemindersRegister.last_run_number.presence || 0
    current_run = last_run_number + 1
    ActiveRecord::Base.transaction do
      @experts_with_active_matches.find_each do |expert|
        basket = select_basket(expert)
        next if basket.nil?
        category = select_category(expert, last_run_number)
        next if category.nil?
        RemindersRegister.create!(expert: expert, basket: basket,
                                  category: category, run_number: current_run,
                                  expired_count: expired_matches(expert).size)
      end
      build_output_basket(last_run_number, current_run)
    end
  end

  private

  def select_basket(expert)
    quo_matches = expert.received_quo_matches.with_status_quo_active
    old_quo_matches = quo_matches.where(sent_at: ..MATCHES_AGE[:old])
    quo_matches_size = quo_matches.size
    has_old_quo_matches = (old_quo_matches.size >= MATCHES_COUNT[:quo])
    # Panier avec plus de 5 besoins en attentes dont 2 superieur à 15 jours
    if has_old_quo_matches &&
      (quo_matches_size > MATCHES_COUNT[:many])
      :many_pending_needs
    # Panier entre 2 et 5 besoins en attentes dont 2 superieur à 15 jours
    elsif has_old_quo_matches &&
      (quo_matches_size >= MATCHES_COUNT[:medium]) &&
      (quo_matches_size <= MATCHES_COUNT[:many])
      :medium_pending_needs
    # Panier avec un nouveau besoin en attente, reçu il y a au moins 3 jours, et le dernier besoin recu avant est vieux de + de 3 mois
    elsif (old_quo_matches.size < MATCHES_COUNT[:medium] && quo_matches.present?) &&
      quo_matches.maximum(:created_at) <= 3.days.ago &&
      (latest_received_match_at(expert).present? && (latest_received_match_at(expert) <= MATCHES_AGE[:prehistorical]))
      :one_pending_need
    end
  end

  def select_category(expert, last_run_number)
    last_register = expert.reminders_registers.find_by(run_number: last_run_number)
    # S'il n'y a pas de reminders_register la semaine passée ou qu'il y en a un pas vu dans les entrées
    if last_register.nil? || (last_register.present? && last_register.input_category? && !last_register.processed?)
      :input
    # Si il y a deja un reminders_register dans les entrées datant de la semaine passée et qu'il est vu ou qu'il était deja dans les paniers
    elsif last_register.present? && ((last_register.input_category? && last_register.processed?) || last_register.remainder_category?)
      :remainder
    end
  end

  def build_output_basket(last_run_number, current_run)
    last_run_reminder_needs = RemindersRegister.where(run_number: last_run_number)
    experts_in_last_run = last_run_reminder_needs.where(category: [:input, :remainder]).map(&:expert)
    experts_in_current_run = RemindersRegister.where(run_number: current_run).map(&:expert)
    # expert qui etaient dans les paniers mais ne le sont plus
    no_longer_in_reminders = experts_in_last_run - experts_in_current_run
    # plus les experts qui sont encore dans les sorties et pas "vu"
    in_outputs_not_processed = last_run_reminder_needs.where(category: :output, processed: false).map(&:expert)
    in_expired_needs_not_processed = last_run_reminder_needs.where(category: :expired_needs, processed: false).map(&:expert)
    expert_for_outputs = no_longer_in_reminders | in_outputs_not_processed | in_expired_needs_not_processed

    expert_for_outputs.each do |expert|
      last_run_register = expert.reminders_registers.find_by(run_number: last_run_number)
      current_expired_count = expired_matches(expert).size
      # L'expert va dans la catégorie "expired_needs" si :
      # - Il a actuellement des besoins expirés (non pris en charge depuis plus de 45 jours)
      # - ET soit de nouveaux besoins ont expiré, soit il était déjà en "expired_needs" non traité
      # Sinon, il va dans "output" (sortie normale car il a traité ses besoins ou n'a plus de besoins actifs)
      if last_run_register.present? && current_expired_count > 0 && (
        (current_expired_count > last_run_register.expired_count) || in_expired_needs_not_processed.include?(expert)
      )
        RemindersRegister.create!(expert: expert, category: :expired_needs, run_number: current_run)
      else
        RemindersRegister.create!(expert: expert, category: :output, run_number: current_run)
      end
    end
  end

  def latest_received_match_at(expert)
    newer_received_match = expert.received_matches.order(sent_at: :desc).first
    expert.received_matches.where.not(id: newer_received_match.id).pluck(:sent_at).max
  end

  def expired_matches(expert)
    expert.received_quo_matches.not_archived.with_status_expired
  end
end
