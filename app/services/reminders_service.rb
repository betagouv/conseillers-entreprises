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

  CHECK_TIME = RemindersRegister::TIME_GENERATION + 1.hour

  def self.create_reminders_registers
    experts_with_active_matches = Expert.not_deleted.with_active_matches
    ActiveRecord::Base.transaction do
      experts_with_active_matches.each do |expert|
        basket = select_basket(expert)
        category = select_category(expert)
        next if basket.nil? || category.nil?
        RemindersRegister.create!(expert: expert, basket: basket, category: category)
      end
      build_output_basket(experts_with_active_matches)
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

  def self.select_category(expert)
    last_register = expert.reminders_registers.last
    last_register_is_recent = last_register&.created_at&.between?(CHECK_TIME.ago, Time.zone.now)
    # S'il n'y a pas de reminders_register la semaine passée ou qu'il y en a un pas vu
    if (expert.reminders_registers.blank? ||
      (last_register.present? && !last_register_is_recent)) ||
      (last_register.present? && last_register_is_recent && !last_register.processed?)
      :input
    # Si il y a deja un reminders_register datant de la semaine passée et qu'il est vu
    elsif last_register.present? &&
      last_register_is_recent
      :remainder
    end
  end

  def self.last_closed_match_at(expert)
    expert.received_matches.done.pluck(:created_at).max
  end

  def self.build_output_basket(experts)
    last_week_reminders_registers = RemindersRegister.where(created_at: CHECK_TIME.ago.., processed: false)
    Expert.where(id: last_week_reminders_registers.map(&:expert).pluck(:id)).where.not(id: experts.ids).each do |expert|
      RemindersRegister.create!(expert: expert, category: :output)
    end
  end
end
