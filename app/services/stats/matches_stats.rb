# module Stats
#   class MatchesStats
#     include BaseStats

#     def main_query
#       Match
#         .joins(:advisor)
#     end

#     def date_group_attribute
#       'matches.created_at'
#     end

#     def filtered(query)
#       if territory.present?
#         query.merge! territory.matches
#       end
#       if institution.present?
#         query.merge! institution.sent_matches
#       end

#       query
#     end

#     def category_group_attribute
#       'matches.status'
#     end

#     def category_name(category)
#       Match.human_attribute_value(:status, category)
#     end

#     def category_order_attribute
#       'matches.status'
#     end
#   end
# end
