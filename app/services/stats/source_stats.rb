# module Stats
#   class SourceStats
#     include BaseStats

#     def main_query
#       Diagnosis
#         .completed
#         .joins(:advisor_institution)
#     end

#     def date_group_attribute
#       'diagnoses.created_at'
#     end

#     def filtered(query)
#       if territory.present?
#         query.merge! territory.diagnoses
#       end
#       if institution.present?
#         query.merge! institution.sent_diagnoses
#       end

#       query
#     end

#     def category_group_attribute
#       Diagnosis.arel_table[:solicitation_id].not_eq(nil)
#     end

#     def category_name(category)
#       # category is a bool, result of the category_group_attribute comparison
#       category ? I18n.t('stats.series.source_category.direct') : I18n.t('stats.series.source_category.visits')
#     end

#     def category_order_attribute
#       category_group_attribute
#     end
#   end
# end
