# frozen_string_literal: true

module Annuaire
  # Filter and compare UsersData during and after an import
  #
  # Annuaire::ImportedUsersData serves as a proxy to Annuaire::UsersData,
  # filtering the returned data (by overriding #grouped_experts)
  class ImportedUsersData
    CHANGES = %i[touched updated created removed].freeze

    # Model classes are decorated; these new attributes are used in the views.
    [::User, ::Expert, ::Antenne].each do |klass|
      klass.attr_accessor :import_change_type # one of CHANGES
      klass.attr_accessor :import_attributes_diff # a HashDiff-style Array of changes
    end
    ::Expert.attr_accessor :import_subjects_changes # Hash of {institution_subject -> CHANGES}

    FILTERS = %i[all referenced_antennes only_imported_users].freeze

    # ImportedUsersData may be created:
    # 1. with `data`, `imported_users` and `old_data`. This is used to **preview** the result of an ongoing (incomplete) import.
    # 2. with `data` and `imported_users`. This is used to **highlight** the result of a past (completed) import.
    # 3. just with `data`. In this case it works simply as a proxy.
    #
    # In **preview** mode, the whole data tree returned by #grouped_experts (`Antenne`s, `Expert`s and `User`s) is annotated with #import_change_type, #import_attributes_diff and #import_subjects_changes (for `Experts`s).
    # In **highlight** mode, only `User`s are annotated.
    # In proxy mode, nothing is annotated.
    #
    # Additionally, in **preview** mode, the returned data tree is filtered according to `filter`.
    # - :only_imported_users : only the data contained in the imported_users is returned. Other antennes and experts are hidden.
    # - :referenced_antennes : users that belong to antennes referenced by imported_users are displayed as well, even if they are not themselves in imported_users.
    # - :all : the whole data tree is returned.
    #
    # @param data [UsersData]
    # @param imported_users [ActiveRecord::Relation, nil] of [User]
    # @param old_data [UsersData]
    # @param filter [Symbol, nil] any of FILTERS
    def initialize(data, imported_users, old_data = nil, filter: :all)
      @data = data
      @imported_users = imported_users
      @old_data = old_data
      @filter = filter || :all
    end

    # Public API
    #
    def grouped_experts
      @grouped_experts ||= begin
        decorate_data
        aggregate_decorations
        filtered_grouped_experts(@data, @filter)
      end
    end

    def highlight? = @imported_users.present?

    def preview? = @old_data.present?

    # Delegate other UsersData methods directly
    delegate :grouped_subjects, :not_invited_users, to: :data
    attr_accessor :data

    # Internal
    #

    # Set values for #import_change_type, #import_attributes_diff and #import_subjects_changes in the data tree
    def decorate_data
      imported_users = (@imported_users || []).index_by(&:email)
      imported_experts = (@imported_users || []).flat_map(&:experts).index_by(&:email)
      imported_antennes = (@imported_users || []).map(&:antenne).index_by(&:name)
      old_users = (@old_data&.users || []).excluding(NO_USER).index_by(&:email)
      old_experts = (@old_data&.experts || []).excluding(NO_EXPERT).index_by(&:email)
      old_antennes = (@old_data&.antennes || []).index_by(&:name)

      @data.grouped_experts.each do |antenne, experts|
        institution = Institution.find(antenne.institution_id)
        experts.each do |expert, users|
          users.each do |user|
            if highlight? || preview?
              decorate_user(user, imported_users[user.email], old_users[user.email])
            end
          end
          if preview?
            decorate_expert(expert, imported_experts[expert.email], old_experts[expert.email])
            if expert.import_change_type.in? %i(touched updated)
              decorate_expert_subject_changes(expert, imported_experts[expert.email], old_experts[expert.email], institution.institutions_subjects)
            end
          end
        end
        if preview?
          decorate_antenne(antenne, imported_antennes[antenne.name], old_antennes[antenne.name])
        end
      end
    end

    # Aggregate changes for `Expert`s and `Antenne`s.
    # - :touched `Expert`s are upgraded to :updated if one of their `User`s has been :updated, :created or :removed.
    # - :touched `Antennes`s are upgraded to :updated if one of their `Experts`s has been :updated, :created or :removed.
    def aggregate_decorations
      @data.grouped_experts.each do |antenne, experts|
        experts.each do |expert, users|
          if expert.import_change_type == :touched
            users_changes = users.map(&:import_change_type).uniq
            subjects_changes = expert.import_subjects_changes.values.uniq
            if users_changes != [:touched] || subjects_changes != [:touched]
              expert.import_change_type = :updated
            end
          end
        end

        if antenne.import_change_type == :touched
          experts_changes = experts.keys.map(&:import_change_type).uniq
          if experts_changes != [:touched]
            antenne.import_change_type = :updated
          end
        end
      end
    end

    # Filter the data grouped experts according to the filter and their #import_change_type
    def filtered_grouped_experts(data, filter)
      touched_filter = Proc.new { it.import_change_type.in?(%i[touched updated created]) }

      case filter
      when :only_imported_users
        grouped_experts = data.grouped_experts.select(&touched_filter)
        grouped_experts.transform_values! { |experts| experts.select(&touched_filter) }
        grouped_experts.each_value do |experts|
          experts.transform_values! { |users| users.select(&touched_filter) }
        end
      when :referenced_antennes
        data.grouped_experts.select(&touched_filter)
      when :all
        data.grouped_experts
      else
        raise ArgumentError
      end
    end

    def attributes_diff(old, new)
      ignored_attributes = %w[id created_at updated_at imported_at]
      old_attributes = old.attributes.except(*ignored_attributes)
      new_attributes = new.attributes.except(*ignored_attributes)
      Hashdiff.best_diff(old_attributes, new_attributes)
    end

    def decorate_user(user, imported_user, old_user)
      if preview?
        if imported_user.present? && old_user.present?
          user.import_attributes_diff = attributes_diff(old_user, user)
          user.import_change_type = user.import_attributes_diff.empty? ? :touched : :updated
        elsif imported_user.present? && old_user.nil?
          user.import_change_type = :created
        elsif imported_user.nil? && old_user.present?
          user.import_change_type = :removed
        end
      else
        # In **highlight** mode we can only return :touched or :removed (we have no old_data)
        user.import_change_type = imported_user.present? ? :touched : :removed
      end
    end

    def decorate_expert(expert, imported_expert, old_expert)
      if imported_expert.present? && old_expert.present?
        expert.import_attributes_diff = attributes_diff(old_expert, expert)
        expert.import_change_type = expert.import_attributes_diff.empty? ? :touched : :updated
      elsif imported_expert.present? && old_expert.nil?
        expert.import_change_type = :created
      elsif imported_expert.nil? && old_expert.present?
        expert.import_change_type = :removed
      end
    end

    def decorate_expert_subject_changes(expert, imported_expert, old_expert, institutions_subjects)
      expert.import_subjects_changes = institutions_subjects.index_with do |institution_subject|
        imported_expert_subject = imported_expert.experts_subjects&.find{ it.institution_subject_id == institution_subject.id }
        old_expert_subject = old_expert.experts_subjects&.find{ it.institution_subject_id == institution_subject.id }

        if imported_expert_subject.present? == old_expert_subject.present? # both present or both blank
          :touched
        elsif imported_expert_subject.present? && old_expert_subject.nil?
          :created
        elsif imported_expert_subject.nil? && old_expert_subject.present?
          :removed
        end
      end
    end

    def decorate_antenne(antenne, imported_antenne, old_antenne)
      if imported_antenne.present? && old_antenne.present?
        antenne.import_change_type = :touched
      elsif imported_antenne.present? && old_antenne.nil?
        antenne.import_change_type = :created # Can't happen in reality: we don’t dynamically create Antennes.
      elsif imported_antenne.nil? && old_antenne.present?
        antenne.import_change_type = :removed
      end
    end
  end
end
