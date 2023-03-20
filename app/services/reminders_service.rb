# frozen_string_literal: true

class RemindersService
  MATCHES_AGE = {
    quo: 15.days.ago,
    done: 3.months.ago
  }

  MATCHES_COUNT = {
    quo: 2,
    many: 5,
    medium: 2
  }

  def self.create_reminders_registers
    experts_with_active_matches = Expert.not_deleted.with_users.with_active_matches
    last_run_number = RemindersRegister.last_run_number.presence || 0
    current_run = last_run_number + 1
    ActiveRecord::Base.transaction do
      experts_with_active_matches.each do |expert|
        basket = select_basket(expert)
        category = select_category(expert, last_run_number)
        next if basket.nil? || category.nil?
        RemindersRegister.create!(expert: expert, basket: basket, category: category, run_number: current_run)
      end
      build_output_basket(experts_with_active_matches, last_run_number, current_run)
    end
  end

  private

  def self.select_basket(expert)
    quo_matches = expert.received_quo_matches.with_status_quo_active
    old_matches = quo_matches.where(created_at: ..MATCHES_AGE[:quo])
    quo_matches_size = quo_matches.size
    has_old_matches = (old_matches.size >= MATCHES_COUNT[:quo])
    # Panier avec plus de 5 besoins en attentes dont 2 superieur à 15 jours
    basket = if has_old_matches &&
      (quo_matches_size > MATCHES_COUNT[:many])
      :many_pending_needs
    # Panier entre 2 et 5 besoins en attentes dont 2 superieur à 15 jours
    elsif has_old_matches &&
               (quo_matches_size > MATCHES_COUNT[:medium]) &&
               (quo_matches_size <= MATCHES_COUNT[:many])
      :medium_pending_needs
    # Panier avec un vieux besoin en attente et le dernier besoin cloturé est vieux de 3 mois
    # Note Claire : ici, pourquoi ` && quo_matches.present?` ? `old_matches.size == 1` ?
    elsif (old_matches.size < MATCHES_COUNT[:medium] && quo_matches.present?) &&
               (last_closed_match_at(expert).present? && (last_closed_match_at(expert) <= MATCHES_AGE[:done]))
      :one_pending_need
    end
  end

  def self.select_category(expert, last_run_number)
    last_register = expert.reminders_registers.find_by(run_number: last_run_number)
    # S'il n'y a pas de reminders_register la semaine passée ou qu'il y en a un pas vu dans les entrées
    if last_register.nil? || (last_register.present? && last_register.input_category? && !last_register.processed?)
      :input
    # Si il y a deja un reminders_register dans les entrées datant de la semaine passée et qu'il est vu ou qu'il était deja dans les paniers
    elsif last_register.present? && ((last_register.input_category? && last_register.processed?) || last_register.remainder_category?)
      :remainder
    end
  end

  def self.last_closed_match_at(expert)
    expert.received_matches.done.pluck(:created_at).max
  end

  def self.build_output_basket(experts, last_run_number, current_run)
    last_run_reminders_registers = RemindersRegister.where(category: :output, processed: false)
      .or(RemindersRegister.where(run_number: last_run_number, category: [:input, :remainder]))
    Expert.where(id: last_run_reminders_registers.map(&:expert).pluck(:id)).where.not(id: experts.ids).each do |expert|
      next if expert.reminders_registers.current_output_category.any?
      RemindersRegister.create!(expert: expert, category: :output, run_number: current_run)
    end
  end
end
