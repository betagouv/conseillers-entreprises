# frozen_string_literal: true

module Annuaire
  # Filter and compare UsersData during and after an import
  class ImportedUsersData
    CHANGES = %i[touched updated created removed].freeze

    # Decorate model classes
    [::User, ::Expert, ::Antenne, ::ExpertSubject].each do |klass|
      klass.attr_accessor :import_change_type
      klass.attr_accessor :import_attributes_diff
    end
    ::Expert.attr_accessor :import_subjects_changes

    FILTERS = %i[all referenced_antennes only_imported_users].freeze

    # @param data [UsersData]
    # @param imported_users [ActiveRecord::Relation, nil] of [User]
    # @param old_data [UsersData]
    # @param filter [Symbol, nil] any of FILTERS
    def initialize(data, imported_users, old_data = nil, filter: :all)
      @data = data
      @imported_users = imported_users
      @old_data = old_data
      @filter = filter || :all

      decorate_data
      filter_data
    end

    attr_accessor :data

    public

    def grouped_experts = @filtered

    delegate :grouped_subjects, :not_invited_users, to: :data

    def preview? = @old_data.present?

    private

    def decorate_data
      @data.grouped_experts.each do |antenne, experts|
        institution = Institution.find(antenne.institution_id)
        experts.each do |expert, users|
          users.each do |user|
            type, diff = user_changes(user)
            user.import_change_type = type
            user.import_attributes_diff = diff
          end

          expert.import_subjects_changes = institution.institutions_subjects.index_with do |institution_subject|
            expert_subject_change(expert, institution_subject)
          end

          type, diff = expert_changes(expert)
          if type == :touched && (users.map(&:import_change_type).uniq != [:touched] || expert.import_subjects_changes.values.uniq != [:touched])
            type = :updated
          end
          expert.import_change_type = type
          expert.import_attributes_diff = diff
        end

        type = antenne_changes(antenne)
        if type == :touched && experts.keys.map(&:import_change_type).uniq != [:touched]
          type = :updated
        end
        antenne.import_change_type = type
      end
    end

    def filter_data
      @filtered = begin
        case @filter
        when :only_imported_users
          grouped_experts = @data.grouped_experts.select do |antenne|
            antenne.import_change_type.in?(%i[touched updated created])
          end
          grouped_experts.transform_values! do |experts|
            experts.select{ |expert| expert.import_change_type.in?(%i[touched updated created]) }
          end
          grouped_experts.each_value do |experts|
            experts.transform_values! do |users|
              users.select{ |user| user.import_change_type.in?(%i[touched updated created]) }
            end
          end
        when :referenced_antennes
          @data.grouped_experts.select do |antenne|
            antenne.import_change_type.in?(%i[touched updated created])
          end
        when :all
          @data.grouped_experts
        else
          raise ArgumentError
        end
      end
    end

    def user_changes(user)
      # without old_data, I can only return :touched or :removed
      if @old_data.nil?
        if @imported_users.nil?
          return nil
        else
          in_imported_set = @imported_users.find{ it.email == user.email }
          return in_imported_set.present? ? :touched : :removed
        end
      end

      old_user = @old_data.users.find{ it.email == user.email }
      in_imported_set = @imported_users.find{ it.email == user.email }

      if old_user.present? && in_imported_set.present?
        old_attributes = old_user.attributes.except("updated_at", "imported_at")
        new_attributes = user.attributes.except("updated_at", "imported_at")
        diff = Hashdiff.best_diff(old_attributes, new_attributes)

        if diff.empty?
          [:touched, diff]
        else
          [:updated, diff]
        end
      elsif old_user.blank? && in_imported_set.present?
        [:created, []]
      elsif old_user&.persisted? && in_imported_set.blank?
        [:removed, []]
      end
    end

    def expert_changes(expert)
      return nil if @old_data.nil?

      old_expert = @old_data.experts.find{ it.email == expert.email }
      in_imported_set = @imported_users.flat_map(&:experts).find{ it.email == expert.email }

      if old_expert.present? && in_imported_set.present?
        old_attributes = old_expert.attributes.except("updated_at", "imported_at")
        new_attributes = expert.attributes.except("updated_at", "imported_at")
        diff = Hashdiff.best_diff(old_attributes, new_attributes)
        if diff.empty?
          [:touched, diff]
        else
          [:updated, diff]
        end
      elsif old_expert.blank? && in_imported_set.present?
        [:created, []]
      elsif old_expert&.persisted? && in_imported_set.blank?
        [:removed, []]
      end
    end

    def expert_subject_change(expert, institution_subject)
      return nil if @old_data.nil?

      # expert_subject = expert&.experts_subjects&.find{ it.institution_subject_id == institution_subject.id }

      old_expert = @old_data&.experts&.find{ it.email == expert.email }
      old_expert_subject = old_expert&.experts_subjects&.find{ it.institution_subject_id == institution_subject.id }
      expert_in_imported_set = @imported_users.flat_map(&:experts).find{ it.email == expert.email }
      in_imported_set = expert_in_imported_set&.experts_subjects&.find{ it.institution_subject_id == institution_subject.id }

      if old_expert_subject.present? == in_imported_set.present? # both present or both blank
        :touched
      elsif old_expert_subject.blank? && in_imported_set.present?
        :created
      elsif old_expert_subject.present? && in_imported_set.blank?
        :removed
      end
    end

    def antenne_changes(antenne)
      return nil if @old_data.nil?

      old_antenne = @old_data.antennes.find{ it.name == antenne.name }
      in_imported_set = @imported_users.flat_map(&:antenne).find{ it.name == antenne.name }

      if old_antenne.present? && in_imported_set.present?
        :touched
      elsif old_antenne.blank? && in_imported_set.present?
        :created # can't happen
      elsif old_antenne.present? && in_imported_set.blank?
        :removed
      end
    end
  end
end
