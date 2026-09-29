# frozen_string_literal: true

module Annuaire
  class UsersData
    attr_reader :grouped_experts

    def initialize(institution, antenne, params, index_search_params, flash, session)
      @institution = institution
      @antenne = antenne
      @params = params
      @index_search_params = index_search_params
      @flash = flash
      @session = session

      retrieve_experts_and_users
    end

    private

    def retrieve_experts_and_users
      @grouped_experts = group_experts
      retrieve_antennes_without_experts if @antenne.blank?
      retrieve_managers_without_experts
      retrieve_users_without_experts
    end

    def retrieve_users_without_experts
      # Note: we can’t use .where.missing(:experts), because the experts relation is customized with .not_deleted
      users_without_experts = User.not_deleted
        .where(antenne: @grouped_experts.keys)
        .joins('LEFT OUTER JOIN experts_users ON experts_users.user_id = users.id')
        .where(experts_users: { expert_id: nil })
        .where.missing(:user_rights_manager)
        .includes(:user_rights_manager)
        .group_by(&:antenne_id)


      @grouped_experts.each do |antenne, experts|
        users_without_experts[antenne.id]&.each do |user|
          experts[Expert.new] = [user]
        end
      end
    end

    def retrieve_managers_without_experts # antenne: [managers: :experts]
      @grouped_experts.each_key do |antenne|
        managers_from_other_antennes = antenne.managers
        managers_from_other_antennes.each do |manager|
          next if manager.experts.any? || manager.deleted?
          @grouped_experts[antenne][Expert.new] = [manager]
        end
      end
    end

    def retrieve_antennes_without_experts
      # Si il y a des filtres de recherche par theme ou sujet
      # on ne prend pas les antennes sans experts pour ne pas polluer l'affichage
      if @index_search_params[:region_code].present? && @index_search_params[:theme_id].blank? && @index_search_params[:subject_id].blank?
        antennes = @institution.antennes_in_region(@index_search_params[:region_code]).where.missing(:experts)
      elsif @index_search_params[:theme_id].blank? && @index_search_params[:subject_id].blank?
        antennes = @institution.antennes.where.missing(:experts)
      else
        antennes = Antenne.none
      end
      antennes.includes(advisors: [:user_rights_manager], managers: [:experts, :user_rights_manager]).find_each do |antenne| # Second request is here
        @grouped_experts[antenne] = { Expert.new => antenne.advisors } if antenne.advisors.any?
      end
    end

    def filtered_experts
      experts = base_experts
        .not_deleted
        .by_region(@index_search_params[:region_code])
        .by_theme(@index_search_params[:theme_id])
        .by_subject(@index_search_params[:subject_id])

      experts.where(id: experts) # Main request is done here.
        .order('antennes.name', 'experts.full_name')
        .includes(:experts_subjects, :territorial_zones, antenne: [managers: [:experts, :user_rights_manager]], users: :user_rights_manager)
    end

    def group_experts
      filtered_experts.group_by(&:antenne).transform_values do |experts|
        experts.index_with do |expert|
          expert.users.presence || [User.new]
        end
      end
    end

    def base_experts
      if @params[:advisor].present?
        searched_user = User.find(@params.expect(:advisor))
        @flash[:table_highlighted_ids] = [searched_user.id]
        experts = @antenne.experts.joins(:antenne)
      elsif @session[:highlighted_antennes_ids] && @antenne.nil?
        users = @institution.advisors.joins(:antenne).where(antenne: { id: @session[:highlighted_antennes_ids] })
        experts = Expert.joins(:antenne).where(antenne: users.map(&:antenne))
      else
        experts = (@antenne || @institution).experts.joins(:antenne)
      end
      @session.delete(:highlighted_antennes_ids)
      experts
    end
  end
end
