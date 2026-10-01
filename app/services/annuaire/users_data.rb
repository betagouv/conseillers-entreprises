# frozen_string_literal: true

module Annuaire
  class UsersData
    include InstitutionsSubjectsSorter

    def initialize(institution, antenne, params, index_search_params, flash, session)
      @institution = institution
      @antenne = antenne
      @params = params
      @index_search_params = index_search_params
      @flash = flash
      @session = session
    end

    def preload
      retrieve_subjects
      retrieve_experts_and_users
      retrieve_not_invited_users

      self
    end

    # @returns [Hash<Theme, Hash<Subject, Array<InstitutionSubject>>>]
    def grouped_subjects
      @grouped_subjects ||= retrieve_subjects
    end

    # @returns [Array<Theme>]
    def themes
      grouped_subjects.keys
    end

    # @returns [Array<Subject>]
    def subjects
      grouped_subjects.values.map(&:keys).flatten
    end

    # @returns [Array<InstitutionSubject>]
    def institutions_subjects
      grouped_subjects.values.map(&:values).flatten
    end

    # @returns [Hash<Antenne, Hash<Expert, Array<User>>>]
    def grouped_experts
      @grouped_experts ||= retrieve_experts_and_users
    end

    # @returns [Array<Antenne>]
    def antennes
      grouped_experts.keys
    end

    # @returns [Array<Expert>]
    def experts
      grouped_experts.values.map(&:keys).flatten
    end

    # @returns [Array<User>]
    def users
      grouped_experts.values.map(&:values).flatten
    end

    # @returns [Array<User>]
    def not_invited_users
      @not_invited_users ||= retrieve_not_invited_users
    end

    private

    def retrieve_subjects
      institutions_subjects_by_theme = @institution.institutions_subjects
        .includes(:subject, :experts_subjects, :not_deleted_experts, theme: [:territorial_zones, :cooperations])
        .sort { |a, b| compare_institution_subjects(a, b) }
        .group_by(&:theme)
        .to_h
      @grouped_subjects = institutions_subjects_by_theme.transform_values{ |is| is.group_by(&:subject) }
    end

    def retrieve_experts_and_users
      experts = base_experts
      experts = filtered_experts(experts)
      grouped_experts = group_experts(experts)
      if @antenne.blank?
        antenne_without_experts = retrieve_antennes_without_experts
        grouped_experts = grouped_experts.merge(antenne_without_experts)
      end

      managers_without_experts = retrieve_managers_without_experts(grouped_experts.keys)
      grouped_experts = grouped_experts.deep_merge(managers_without_experts)

      users_without_experts = retrieve_users_without_experts(grouped_experts.keys)
      grouped_experts = grouped_experts.deep_merge(users_without_experts)

      @grouped_experts = grouped_experts
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

    def filtered_experts(experts)
      experts = experts
        .not_deleted
        .by_region(@index_search_params[:region_code])
        .by_theme(@index_search_params[:theme_id])
        .by_subject(@index_search_params[:subject_id])

      experts.where(id: experts) # Main request is done here.
        .order('antennes.name', 'experts.full_name')
        .includes(:experts_subjects, :territorial_zones, antenne: [managers: [:experts, :user_rights_manager]], users: :user_rights_manager)
    end

    def group_experts(experts)
      experts.group_by(&:antenne).transform_values do |antenne_group|
        antenne_group.index_with do |expert|
          expert.users.presence || [User.new]
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
      result = {}
      antennes.includes(advisors: [:user_rights_manager], managers: [:experts, :user_rights_manager]).find_each do |antenne| # Second request is here
        result[antenne] = { Expert.new => antenne.advisors } if antenne.advisors.any?
      end
      result
    end

    def retrieve_managers_without_experts(antennes) # antenne: [managers: :experts]
      result = {}
      antennes.each do |antenne|
        managers_from_other_antennes = antenne.managers
        managers_from_other_antennes.each do |manager|
          next if manager.experts.any? || manager.deleted?
          result[antenne] = { Expert.new => [manager] }
        end
      end
      result
    end

    def retrieve_users_without_experts(antennes)
      # Note: we can’t use .where.missing(:experts), because the experts relation is customized with .not_deleted
      users_without_experts = User.not_deleted
        .where(antenne: antennes)
        .joins('LEFT OUTER JOIN experts_users ON experts_users.user_id = users.id')
        .where(experts_users: { expert_id: nil })
        .where.missing(:user_rights_manager)
        .includes(:user_rights_manager)
        .group_by(&:antenne_id)


      result = {}
      antennes.each do |antenne|
        users_without_experts[antenne.id]&.each do |user|
          result[antenne] = { Expert.new => [user] }
        end
      end
      result
    end

    def retrieve_not_invited_users
      if @flash[:table_highlighted_ids].present?
        User.not_deleted.where(id: @flash[:table_highlighted_ids]).where(invitation_sent_at: nil).load
      else
        antennes = grouped_experts.keys
        User.not_deleted.joins(:antenne).where(antenne: antennes, invitation_sent_at: nil).load
      end
    end
  end
end
