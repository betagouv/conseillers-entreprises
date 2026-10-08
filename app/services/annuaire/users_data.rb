# frozen_string_literal: true

module Annuaire
  class UsersData
    include InstitutionsSubjectsSorter

    # Preload the whole data tree to fill the Annuaire::Users table
    # @param institution [Institution]
    # @param antenne [Antenne, nil]
    # @param base_experts an ActiveRecord::Relation merged in the main experts query for additional filtering
    # @param base_antennes an ActiveRecord::Relation merged in the antenes without experts query for additional filtering
    def initialize(institution, antenne, base_experts: Expert.all, base_antennes: Antenne.all)
      @institution = institution
      @antenne = antenne
      @base_experts = (@antenne || @institution).experts.merge(base_experts).not_deleted
      @base_antennes = @institution.antennes.merge(base_antennes).not_deleted
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

    def retrieve_subjects
      institutions_subjects_by_theme = @institution.institutions_subjects
        .includes(:subject, :experts_subjects, :not_deleted_experts, theme: [:territorial_zones, :cooperations])
        .strict_loading!
        .sort { |a, b| compare_institution_subjects(a, b) }
        .group_by(&:theme)
        .to_h
      @grouped_subjects = institutions_subjects_by_theme.transform_values{ |is| is.group_by(&:subject) }
    end

    def retrieve_experts_and_users
      grouped_experts = group_experts

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

    def filtered_experts # This is the main Experts query
      @base_experts
        .joins(:antenne)
        .order('antennes.name', 'experts.full_name')
        .includes(:experts_subjects, :territorial_zones, antenne: [:territorial_zones, :parent_antenne, :child_antennes, :institution, managers: [:experts, :user_rights_manager]], users: :user_rights_manager)
        .strict_loading!
    end

    def group_experts
      filtered_experts.group_by(&:antenne).transform_values do |antenne_group|
        antenne_group.index_with do |expert|
          expert.users.presence || [User.new]
        end
      end
    end

    def retrieve_antennes_without_experts
      antennes = @base_antennes.where.missing(:experts)

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
      users_without_experts = User.not_deleted
        .where(antenne: antennes)
        .joins('LEFT OUTER JOIN experts_users ON experts_users.user_id = users.id') # Note: we can’t use .where.missing(:experts), because the experts relation is customized with .not_deleted
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
      users.filter{ |user| user.invitation_sent_at.nil? }
      User.not_deleted.joins(:antenne).where(antenne: antennes, invitation_sent_at: nil).load
    end
  end
end
