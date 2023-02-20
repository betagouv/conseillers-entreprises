# frozen_string_literal: true

class RemindersService
  def self.create_reminders_registers
    experts_with_quo_needs = Expert.with_active_matches
    ActiveRecord::Base.transaction do
      experts_with_quo_needs.each do |expert|
        basket = select_basket(expert)
        category = select_category(expert)
        next if basket.nil? || category.nil?
        RemindersRegister.create!(expert: expert, basket: basket, category: category)
      end
      build_output_basket(experts_with_quo_needs)
    end
  end

  private

  def self.select_basket(expert)
    quo_active_matches = expert.received_quo_matches.with_status_quo_active
    old_needs = quo_active_matches.where(created_at: ..RemindersRegister::MATCHES_AGE[:quo])
    quo_active_matches_size = quo_active_matches.size
    # Panier avec plus de 5 besoins en attentes dont 2 superieur à 15 jours
    basket = if (old_needs.size >= RemindersRegister::MATCHES_COUNT[:quo]) &&
      (quo_active_matches_size > RemindersRegister::MATCHES_COUNT[:many])
      :many_pending_needs
    # Panier entre 2 et 5 besoins en attentes dont 2 superieur à 15 jours
    elsif (old_needs.size >= RemindersRegister::MATCHES_COUNT[:quo]) &&
               (quo_active_matches_size >= RemindersRegister::MATCHES_COUNT[:medium]) &&
               (quo_active_matches_size <= RemindersRegister::MATCHES_COUNT[:many])
      :medium_pending_needs
    # Panier avec un besoin en attente et le dernier besoin cloturé est vieux de 3 mois
    elsif (old_needs.size < RemindersRegister::MATCHES_COUNT[:medium] && quo_active_matches.present?) &&
               (last_closed_need_at(expert).present? && (last_closed_need_at(expert) <= RemindersRegister::MATCHES_AGE[:done]))
      :one_pending_need
    end
  end

  def self.select_category(expert)
    # Si il y a deja un reminders_register datant de la semaine passée
    if expert.reminders_registers.last.present? && expert.reminders_registers.last.created_at.between?(8.days.ago, Time.zone.now)
      :remainder
      # S'il n'y a pas de reminders_register la semaine passée
    elsif expert.reminders_registers.blank? ||
      (expert.reminders_registers.last.present? && !expert.reminders_registers.last.created_at.between?(8.days.ago, Time.zone.now))
      :input
    end
  end

  def self.last_closed_need_at(expert)
    expert.received_matches.done.pluck(:created_at).max
  end

  def self.build_output_basket(experts)
    last_week_reminders_registers = RemindersRegister.where(created_at: 8.days.ago..)
    Expert.where(id: last_week_reminders_registers.map(&:expert).pluck(:id)).where.not(id: experts.ids).each do |expert|
      RemindersRegister.create!(expert: expert, category: :output)
    end
  end
end
